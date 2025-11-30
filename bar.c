#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <sys/wait.h>

#include <stdbool.h>

#define MODULE_OUTPUT_BUFFER_LENGTH 128
#define CORE_ENVIRONMENT_INIT_ERROR -1

static struct {
  const char *custom_modules_dir;
  const char *default_modules_dir;
  const char *cache_dir;
  const char *separator;
  const char *left_padding;
  const char *right_padding;
  const char *interval_ms;

} s_runtime_constants = {NULL};

struct module_process_block {
  int pid;
  FILE *fp;
};

int initialise_runtime_constants(void) {
  if (!(s_runtime_constants.custom_modules_dir = getenv("CUSTOM_DIR"))) {
    return CORE_ENVIRONMENT_INIT_ERROR;
  }

  if (!(s_runtime_constants.default_modules_dir =
            getenv("DEFAULT_MODULES_DIR"))) {
    return CORE_ENVIRONMENT_INIT_ERROR;
  }

  // TODO: Set up the cache directory

  // Set up strings
  if (!(s_runtime_constants.separator = getenv("SEPARATOR"))) {
    s_runtime_constants.separator = "|";
  }

  if (!(s_runtime_constants.left_padding = getenv("LEFT_PADDING"))) {
    s_runtime_constants.left_padding = " ";
  }

  if (!(s_runtime_constants.right_padding = getenv("RIGHT_PADDING"))) {
    s_runtime_constants.right_padding = " ";
  }

  // Delay
  if (!(s_runtime_constants.interval_ms = getenv("DELAY"))) {
    s_runtime_constants.interval_ms = "1000";
  }

  // All good
  return 1;
}

/**
 * Path join with two strings
 */
char *build_path(const char *const str1, const char *const str2) {
  // FIXME: This function is not robust at all.
  int len = strlen(str1) + strlen(str2) + 1;

  // Build the combined string
  char *combined = calloc(len, sizeof(char));
  sprintf(combined, "%s/%s", str1, str2);

  return combined;
}

char *find_module(const char *basename) {
  static const int k_permissions_to_check = R_OK | X_OK | F_OK;
  // Get the path for the custom location
  char *custom_location =
      build_path(s_runtime_constants.custom_modules_dir, basename);

  if (access(custom_location, k_permissions_to_check) == 0)
    return custom_location;
  free(custom_location);

  char *default_location =
      build_path(s_runtime_constants.default_modules_dir, basename);
  if (access(default_location, k_permissions_to_check) == 0)
    return default_location;
  free(default_location);

  return NULL;
}

struct module_process_block run_module(const char *const module_name) {
  // Does the module exist in the custom modules directory?
  char *module_path = find_module(module_name);

  if (!module_path)
    return (struct module_process_block){0};

  // Create the pipe
  int fds[2] = {0};
  int pipe_success = pipe(fds); // TODO: Error handle

  // Fork the process
  pid_t pid = fork();
  if (pid == 0) {
    // We are the child

    // Set up our stdout to be the input of the pipe
    dup2(fds[1], STDOUT_FILENO);

    // Switch into the new program
    execl(module_path, module_path, NULL);

    exit(0);
  } else {
    // We're the parent
    // Close the write end
    close(fds[1]);

    // Open the read file descriptor as a full file
    FILE *output = fdopen(fds[0], "r");

    free(module_path);

    return (struct module_process_block){.pid = pid, .fp = output};
  }
}

/*
 * List of module paths
 */
int main(int argc, char **argv) {
  int ret = initialise_runtime_constants();
  if (ret < 1)
    return ret;

  char *modules_str = getenv("MODULES");
  char *online_modules_str = getenv("ONLINE_MODULES");
  int module_count = 1;
  if (!modules_str)
    return 1;

  if (strlen(modules_str) == 0)
    return 1;

  // Figure out how many modules there are - delimited by spaces
  for (size_t i = 0; i < strlen(modules_str); i++) {
    if (modules_str[i] == ' ') {
      module_count++;
    }
  }

  // with the count, allocate a table to store the strings

  char **module_names = calloc(module_count, sizeof(char *));

  // Extract each module's name
  int last_start = 0;
  int module = 0;
  for (size_t i = 0; i <= strlen(modules_str); i++) {
    if (modules_str[i] == ' ' || modules_str[i] == '\0') {
      int name_length = i - last_start;
      module_names[module] = calloc((name_length), sizeof(char));
      memcpy(module_names[module], modules_str + last_start,
             sizeof(char) * (name_length));
      module_names[module][name_length] = 0;
      last_start = i + 1;
      module++;
    }
  }

  struct module_process_block *processes =
      calloc(module_count, sizeof(struct module_process_block));

  // Start all the modules
  for (int i = 0; i < module_count; i++) {
    processes[i] = run_module(module_names[i]);

    if (processes[i].pid == 0) {
      // TODO: Properly handle
      fprintf(stderr, "Error running module #%d\n", i);
    }
  }

  // Wait on the modules in sequence
  for (int i = 0; i < module_count; i++) {
    // Wait on the pid
    char *s = NULL;
    size_t len;
    ssize_t read;
    int sl = 0;
    waitpid(processes[i].pid, &sl, 0);

    while((read = getline(&s, &len, processes[i].fp)) == -1);

    for (size_t i = 0; i < read; i++) {
        if (s[i] == '\n') {
            s[i] = '\0';
            break;
        }
    }

    printf("%s%s%s", s_runtime_constants.left_padding, s, s_runtime_constants.right_padding);

    free(s);

    fclose(processes[i].fp);

    if (i != module_count - 1) {
      printf("%s", s_runtime_constants.separator);
    }
  }

  free(module_names);
  free(processes);

  putchar('\n');

  return 0;
}

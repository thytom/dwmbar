#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>

#include <stdbool.h>

#define MODULE_OUTPUT_BUFFER_LENGTH 128
#define CORE_ENVIRONMENT_INIT_ERROR -1

static struct {
    const char* custom_modules_dir;
    const char* default_modules_dir;
    const char* cache_dir;
    const char* separator;
    const char* left_padding;
    const char* right_padding;
    const char* interval_ms;

} s_runtime_constants = {
    NULL
};

int initialise_runtime_constants(void) {
    if (!(s_runtime_constants.custom_modules_dir = getenv("CUSTOM_DIR"))) {
        return CORE_ENVIRONMENT_INIT_ERROR;
    }

    if (!(s_runtime_constants.default_modules_dir = getenv("DEFAULT_MODULES_DIR"))) {
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
char* build_path(const char *const str1, const char *const str2) {
    // FIXME: This function is not robust at all.
    int len = strlen(str1) + strlen(str2) + 1;

    // Build the combined string
    char *combined = calloc(len, sizeof(char));
    sprintf(combined, "%s/%s", str1, str2);


    return combined;
}

char* find_module(const char* basename) {
    static const int k_permissions_to_check = R_OK | X_OK | F_OK;
    // Get the path for the custom location
    char *custom_location = build_path(s_runtime_constants.custom_modules_dir, basename);
    if (access(custom_location, k_permissions_to_check) == 0) return custom_location;
    free(custom_location);

    char *default_location = build_path(s_runtime_constants.default_modules_dir, basename);
    if (access(default_location, k_permissions_to_check) == 0) return default_location;
    free(default_location);

    return NULL;
}

bool run_module(char *output_buffer, const char*const module_name) {
    // Does the module exist in the custom modules directory?
    char *module_path = find_module(module_name);

    if (!module_path) return NULL;

    FILE *output = popen(module_path, "r");

    char *s = NULL;
    size_t i = 0;

    while((s = fgetln(output, &i)) == NULL);

    memcpy(output_buffer, s, i-1);

    if (pclose(output) != 0) {
        fprintf(stderr, "Error!");
    }

    free(module_path);

    return NULL;
}

/*
 * List of module paths
 */
int main(int argc, char **argv) {
    int ret = initialise_runtime_constants();
    if (ret < 1) return ret;

    if (argc == 1) {
        fprintf(stderr, "Bar requires at least one argument (a module)");
        return 1;
    }


    // Allocate the table - just a big chunk of memory, faster alloc
    char *output_table = calloc(argc - 1, sizeof(char) * MODULE_OUTPUT_BUFFER_LENGTH);

    // Take the module
    for (int i = 1; i < argc; i++) {
        run_module(&output_table[(i - 1) * MODULE_OUTPUT_BUFFER_LENGTH], argv[i]);
    }

    for (int i = 1; i < argc; i++) {
        printf("%s", &output_table[(i-1) * MODULE_OUTPUT_BUFFER_LENGTH]);

        if (i != argc - 1) {
            printf("%s%s%s", s_runtime_constants.left_padding, s_runtime_constants.separator, s_runtime_constants.right_padding);
        }
    }

    putchar('\n');

    free(output_table);

    return 0;
}

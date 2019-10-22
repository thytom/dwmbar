dwmbar - A Modular Status Bar for dwm
=====================================

dwmbar is a very simple status bar written for dwm.

# Installation

## Arch Linux

There is an [AUR package](https://aur.archlinux.org/packages/dwmbar) for
dwmbar, which can be installed with your favourite aur helper, or manually.

Please see the [archwiki
page](https://wiki.archlinux.org/index.php/Arch_User_Repository#Installing_packages)
for how to manually install packages.

## Manual Installation

```bash
$ git clone https://github.com/thytom/dwmbar
$ cd dwmbar
$ sudo install.sh
```
# Usage

dwmbar works by setting the root window name, which dwm displays. It does this
by calling the dwmbarrc file in your .config/dwmbar folder.

Add the line `dwmbar &` to your .xinitrc file to run on startup. You can also
run `dwmbar` in terminal for testing purposes.

# Customisation

## Configuring the Bar

Most non-modular configuration is done in `~/.config/dwmbar/dwmbarrc`, a bash
script that calls scripts in turn, caching their output and then constructing
the bar from that.

To add a module to the bar, simply include its name in the MODULES variable:

```bash
MODULES="mpd volumebar wifi battery"
```

Modules are displayed left-to-right in the order they are written in `MODULES`.
By default, they are delimited by the `SEPARATOR` variable, which you can
change.

We also offer a `PADDING` variable, which contains a string you can include at
the start of your bar, on the very right. This can either be padding spaces, to
move the bar away from the right edge, or even text. By default, we set
`PADDING` to `$USER@$HOSTNAME`. Feel free to change this.

### About dwmbarrc

**Because we expect people to modify `dwmbarrc`, and so we will never update
it. dwmbar will automatically create it if it is not there, but once it is
there, it must be deleted for another up-to-date version to be given.**

Interestingly, so long as dwmbarrc prints *something* to stdout, it does not
matter what it's written in, or what it does. So if you want to write your own
implementation and use that, go nuts :smile:.

## Writing Modules

Default modules are located within `~/.config/dwmbar/modules`, and custom
modules can be placed in `~/.config/dwmbar/modules/custom`. If a default module
exists with the same name as a custom module, then the custom module will take
precedence.

**Default modules will possibly be overwritten during updates, so if you want
to modify them be sure to make a copy in the custom folder, which will not be
touched, and edit it there.**

Modules can be written in any language, so long as they are executable and
print their output to stdout.

Currently available default modules are:
- archupdates		Gets the number of updates available **Arch Linux Only**
- backlight			Shows the brightness of the screen
- battery			Gets battery percentage
- bluetooth			Shows bluetooth status
- cpuload			Shows the CPU load in %
- date				Shows the calendar date
- daypercentage		Shows how far through the day you are, in %
- disksize			Shows the disk usage
- ethernet			Shows ethernet connection
- internet			Shows whether internet is available (TODO)
- mail				Shows how much mail you have
- mpd				Shows MPD status
- ram				Shows RAM usage
- redshift			Shows current screen temperature from Redshift
- sunmoon			Displays a sun or moon for time of day
- temperature		Displays the temperature of the CPU
- time				Displays time
- todo				Prints the number of todos for the "t" todo manager
- tor				Prints if the tor service is enabled
- volume			Prints volume in %
- volumebar			Displays a volume bar
- weather			Shows weather info
- wifi				Shows wifi connection




# Possible Features


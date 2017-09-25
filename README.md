# My prompt for bash

These files allow to have:
- `my.prompt.bash` - a nice prompt with time, path and **git branch**
- `pushbullet.bash` - simple PushBullet notification on your phone from command line
- `long.command.bash` - a notice about the execution time after each command longer then ..., and a PushBullet notification for commands longer then ...

Best. Prompt. Ever.

## PushBullet
The `pushbullet.bash` file provides a **very** simple bash function to show notifications on your phone using PushBullet. The service is free in the capabilities used here. To use it you can login with Google or Facebook. I chose it because it has a very simple http API - so you can interact with it with `curl` (which is exactly what the script does).

To use it, just install the PushBullet app on your phone, and **generate a token** on the PushBullet page. Then set `PB_TOKEN` env variable with this token.

## Usage in console
### Nice prompt
Just add the following lines to your `.bashrc`:
```bash
source .../my.prompt.bash
```

You will get a nice bash prompt, displaying:
- Time
- Host you are on
- Path you are in
- (if you are in a git repo) identifier of the commit you are on, and the branch

### Long command
Just add the following lines to your `.bashrc`:
```bash
export PB_TOKEN=...your token...
source .../pushbullet.bash
source .../long.command.bash
```

Then if you execute something which takes a longer time (LONG_COMMAND env variable) you will get a notice after it:

![Notification](https://raw.githubusercontent.com/llaniewski/my.prompt/pictures/kons1.gif)

And if the command will take a **lot** of time to execute (VERY_LONG_COMMAND env var), you will get a notification on your phone:

![Notification](https://raw.githubusercontent.com/llaniewski/my.prompt/pictures/kom1.gif)

#### Exceptions
There is not apparent way for the console to know **why** a command took a lot of time. Maybe it was an text editor!

You can add exceptions in the LONG_COMMAND_EXCEPTIONS env variable, separated by `|`.

```bash
LONG_COMMAND_EXCEPTIONS="$LONG_COMMAND_EXCEPTIONS|gedit|paraview"
```

There is also a LONG_COMMAND_PATTERN, which is a `grep -E` pattern to check for exceptions, if you want to define a complex one.

## Usage in scripts
The `pushbullet.bash` file can be also usefull in scripts (for instance PBS or SLURM batch works). You can use it like this:
```bash
# Some important initializacji
source .../pushbullet.bash
pb_msg "My Job" "I just started"
# Some important first step
pb_msg "My Job" "I finished first step"
# Some calculations
pb_msg "My Job" "Finished"
```

## No more mess
The `pb_msg` function is storing the ID of the previous notification, and discarts it when you make another. This is specific to the bash shell you are running in - this means that you will get **one notification** per shell/script, and if something new happens, this notification will dissapear and a new will appear (with a buzz).

## Open it, gut it, make it better.
These scripts are intentended for people capable of writing ane reading `bash` scripts. Please remember that downloading scripts from the internet and running them without reading is *dengerous*, to say the least. **Edit them and adjust them to your needs.**

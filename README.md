# My prompt for bash

These files allow to have:
- `my.prompt.bash` - a nice prompt with time, path and **git branch**
- `pushbullet.bash` - simple PushBullet notification on your phone from command line
- `long.command.bash` - a notice about the execution time after each command longer then ..., and a PushBullet notification for commands longer then ...

Best. Prompt. Ever.

## PushBullet
The `pushbullet.bash` file provides a **very** simple bash function to show notifications on your phone using PushBullet. The service is free in the capabilities used here. To use it you can login with Google or Facebook. I chose it because it has a very simple http API - so you can interact with it with `curl` (which is exactly what the script does).

## Usage in console
Just add the following lines to your `.bashrc`:
```bash
export PB_TOKEN=...your token...
source .../my.prompt.bash
source .../pushbullet.bash
source .../long.command.bash
```

You will get a nice bash prompt, displaying:
- Time
- Host you are on
- Path you are in
- (if you are in a git repo) identifier of the commit you are on, and the branch

### Long command
Then if you execute something which takes a longer time (LONG_COMMAND env variable) you will get a notice after it:
![Notification](https://raw.githubusercontent.com/llaniewski/my.prompt/pictures/kons1.gif)

And if the command will take a **lot** of time to execute (VERY_LONG_COMMAND env var), you will get a notification on your phone:
![Notification](https://raw.githubusercontent.com/llaniewski/my.prompt/pictures/kom1.gif)

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

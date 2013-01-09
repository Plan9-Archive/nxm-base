.FP lucidasans
.HTML "Cares for Mercury Poisoning
.TL
Cares for Mercury Poisoning
.br
A tutorial for NIX's patch(1)
.AU
Francisco J. Ballesteros
nemo@lsub.org
.AB
Mercury poisoning (also known as hydrargyria or mercurialism) is a
disease caused by exposure to mercury or its compounds.
This document describes how to use NIX's patch(1) to avoid
exposure to dangerous metal compounds.
.AE
.SH
Motivation
.PP
Plan 9 uses patches for sending contributions and a file replica tool to update
installations. For some time, NIX used mercurial to propagate updates and contributions.
But this had a number of problems.
.IP 1
The tool is not well suited to distribute binaries and does not preserve permissions.
.IP 2
The Plan 9 support for the tool is buggy, to say the least.
.IP 3
The tool is a departure from UNIX development in that you lose control over your
files, and it's not easy to edit updates and/or fix problems when they happen.
.IP 4
Last but not least, it's not fun.
.LP
As an effort to make it easier and more amenable to contribute to NIX and to
update NIX installations,
.I patch (1)
was written.
.PP
.I Patch
is a set of simple scripts that try to preserve the following properties:
.IP 1
Patches should have an easy to understand structure. If there are problems, users
should be able to edit them and/or fix them.
.IP 2
Patches should not depend on time-stamps, or other coherency enforcing
mechanisms that force users to remove everything, and reinstall everything to
get back into a coherent state. This happen to some replica users.
.IP 3
Patches should respect changes made to a local installation, and respect the
user's freedom to customize the local system.
.SH
User interface
.LP
There are a few scripts available:
.IP \(bu
.I Patch/create
can be used to create a patch.
.IP \(bu
.I Patch/pull
can be used to update a local installation.
.LP
Other tools are aimed at people maintaining the distribution, and will be
described later.
.SH
Patch creation
.LP
To create a patch, you can supply a list of files (and/or directories!) that
change. Perhaps some of them have been removed, in which case the patch
will try to remove them when applied. For example:
.P1
; rm -rf /386/bin/hg /sys/src/cmd/hg
; patch/create noexposure nemo@lsub.org /386/bin/hg /sys/src/cmd/hg <<EOF
Remove things dangerous for health.
EOF
;
.P2
.LP
would create a patch called
.I noexposure
that would remove the named files when applied. Well, actually, it would not remove
anything, but print commands you can run to remove them.
.PP
A more usual example is creating a patch that adds or edits some files:
.P1
; patch/create pwd-errors user@host.dom /sys/src/cmd/pwd.c /386/bin/pwd
Fix pwd to print errors to fd 2 rather than 1.
^D
.P2
.LP
This creates a patch would change
.I pwd
when applied, and include a new binary for the command.
.PP
The created patch is kept at
.I patches.lsub.org
for others to look, until it's applied or forgotten.
.SH
Listing patches
.LP
At any time, you can run
.I patch/list
to see which patches are still out for discussion, but are not yet applied to the
distribution:
.P1
; patch/list
Apr 18 11:55 morepmc: Changes in the pmc that somehow got lost.
Apr 19 05:55 cppnsec: The change in nsec() not to cache fds broke cpp.
Apr 19 07:00 liberror: rename nerrors to errstacksize in liberror
Apr 19 10:10 plan9-20120419: Sync with plan 9 as of today.
Apr 19 10:20 realloc: Ptal, I followed what lucio/forsyth suggested and added a delta variable.
.P2
.LP
You could also list all the patches, including those already applied:
.P1
; patch/list -a
Apr 13 10:49 applied newprocess: Describe the new contribution process using patch(1).
Apr 13 10:52 applied patchman: man updated for nix patch(1).
.B ...
.P2
.LP
Or ask for more information about one patch (or all patches):
.P1
; patch/list -v newup
applied: newup
date: Apr 18 09:55
	New version of up to use in the upcomming patch/pullbin.
from: nemo@lsub.org
files:
	/386/bin/up up
	/sys/src/cmd/up.c up.c
	/sys/man/1/up up.1
removed:
.P2
.LP
Under
.I files
you get a list of files that are new or changed (they are listed in a file named
.I files
within the patch directory).
Under
.I removed
you get a list of files that are going to be removed (listed in a file named
.I removed
within the patch directory).
.SH
Pulling patches
.LP
To get your NIX installation up to date with respect to the distribution, you can run
.I patch/pull
as shown:
.P1
; patch/pull
patch/apply creepyhalt
/dist/patch/creepyhalt
merge...conflicts merging /sys/src/cmd/creepy/9p.c; 
	see /n/dist/dist/patch/creepyhalt/9p.c.new
conflicts merging /sys/src/cmd/creepy/cfg.c;
	see /n/dist/dist/patch/creepyhalt/cfg.c.new
conflicts merging /sys/src/cmd/creepy/fsys.c;
	see /n/dist/dist/patch/creepyhalt/fsys.c.new
conflicts merging /sys/src/cmd/creepy/ix.c;
	see /n/dist/dist/patch/creepyhalt/ix.c.new
exiting without changes
apply failed
.P2
.LP
In this example, we have shown that
.I apply
detected some local changes and declared a conflict between the patch and your
local editions.
.PP
.I Patch/pull
takes all the patches applied to the main distribution an applies one by one to your tree
until one fails or all have been applied.
.PP
If we have our
.I / '' ``
mounted read-only, or want to pull to a different tree, we can bind at
.I /n/dist
the tree to be patched. If there is no tree bound there,
.I pull
(or actually,
.I apply )
binds your
.I / '' ``
directory there.
For example, under 9vx we could:
.P1
; bind -c '#Z/usr/nemo/nix-os' /n/dist 
; patch/pull
.B ...
.P2
.SH
Conflicts
.LP
What do we do upon conflicts? Here is where the simple structure of a patch helps.
In the example of the last section, we had conflicts for files:
.I 9p.c ,
.I cfg.c ,
and
.I ix.c .
.PP
First, we have to see what to do. As you may note from the output shown in the
example of the previous section, you were asked to see files like
.I /n/dist/dist/patch/creepyhalt/9p.c.new .
.PP
In your local tree, that file is actually at
.I /dist/patch/creepyhalt/9p.c.new .
Patches that are being applied are copied to
.I /dist/patch
where it's more convenient for you to edit and/or adjust them at will before
retrying to apply them.
.PP
The original file by the time of the patch creation for
.I 9p.c
can be found in
.I 9p.c.orig ,
at the patch directory. So, this reports the diferences between what you
were expected to have, and your local version for the file:
.P1
; diff /dist/patch/creepyhalt/9p.c.orig /sys/src/cmd/creepy/9p.c
31c31
< ninestats(char *s, char *e, int clr, int verb)
---
> ninestats(char *s, char *e, int clr)
.B ...
.P2
.LP
You may take several courses of action:
.IP \(bu
Drop your changes. This can be done by simply copying the original file
as it was expected to be to your file:
.P1
; cp -x /dist/patch/creepyhalt/9p.c.orig /sys/src/cmd/creepy/9p.c
.P2
.LP
.IP \(bu
Drop the changes in the distribution. Easy!, just remove the file from the
list of files to be patched:
.P1
; B /dist/patch/creepyhalt/files
.I "... edit the file to remove the line for 9p.c ...
.P2
.LP
.IP \(bu
Hand-edit the merge that failed.
.P1
; cp -x /dist/patch/creepyhalt/9p.c.new /sys/src/cmd/creepy/9p.c
; B /sys/src/cmd/creepy/9p.c
.I "... locate the <<<<< and >>>> lines and edit at will ...
; B /dist/patch/creepyhalt/files
.I "... edit the file to remove the line for 9p.c ...
.P2
.IP
An alternative could be to to copy the
.I 9p.c.new
to
.I 9p.c
in the patch directory, and then  copy
.I 9p.c.orig
from the patch directory to your local version, after editing
.I 9p.c.new .
.LP
In general, you are welcome to edit the
.I /dist/patch/*/files
and
.I /dist/patch/*/removed
files that list new or changed files and removed files.
.PP
After resolving the conflicts, you can run
.I patch/pull
again. It will use your local version for the patch as kept in
.I /dist/patch .
.PP
Another trick is to adjust the contents of
.I /dist/patch/applied .
That file contains the names of patches that have been applied.
Thus, you can add a name there to skip or ignore that patch.
.I Pull
takes the list of applied patches from the main distribution, your one,
and then goes one by one trying to apply patches that you have not yet applied.
This command does also the trick:
.P1
; patch/applied creepyhalt
.P2
.LP
In this section we could see conflicts for files that exist. However, the conflict
may happen because the file was removed, or because it was not removed.
The process in this case is exactly the same. When the
.I .orig
file does not exist in the patch directory, that means that the file was not
expected to exist in your tree.
.PP
Also, files to be removed when applying the patch are simply listed at
.I /dist/patch/*/removed ,
and you are of course welcome to edit that file.
.PP
The apply process will usually not remove any of your files, but print
commands that you could run to remove them if you want.
.SH
Reviewing code
.LP
You might want to try a patch to drop some comments on it for reviewing.
This can be done as follows:
.P1
; patch/apply newup
/dist/patch/newup
merge...backup...copy...
cpfile up /n/dist/386/bin/up
cpfile up.c /n/dist/sys/src/cmd/up.c
cpfile up.1 /n/dist/sys/man/1/up
done
.P2
.LP
Now you can play with the new
.I up
from the patch. Once you are done, you can get back to where you were
before applying this patch by running:
.P1
; patch/undo newup
.B ...
.P2
.LP
This relies on the
.I .backup
files copied to the patch directory to restore your previous state.
.PP
.SH
Updating a patch
.LP
So, what do we do if due to a review or to a change of mind we
want to update a patch? Easy. We just create it again with the new
set of files relevant for the patch (added, changed, or removed files).
A new mail will be sent notifying the patch creation, and that must
be understood as an update for the patch.
The old versions for the patch are kept in sibling (renamed) directories,
until the patch is applied to the main distribution.
.SH
When everything fails...
.LP
Remember that patches can be edited.
First, you should probably make sure that your set of
.I patch
scripts is up to date. Newer versions of
.I patch
take care of that by showing you which commands you have to run
to update it when needed. But, in any case, we can always:
.P1
; 9fs sources.lsub.org
post...
; fcp -x /n/sources.lsub.org/nix/rc/bin/patch/* /rc/bin/patch
.P2
.LP
Or using
.I up (1)
perhaps...
.P1
; 9fs sources.lsub.org
; up /n/sources.lsub.org/nix/rc/bin/patch /rc/bin/patch |rc
.P2
.LP

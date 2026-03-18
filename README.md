[![Build status](https://github.com/git/git/workflows/CI/badge.svg)](https://github.com/git/git/actions?query=branch%3Amaster+event%3Apush)

Git - fast, scalable, distributed revision control system
=========================================================

Git is a fast, scalable, distributed revision control system with an
unusually rich command set that provides both high-level operations
and full access to internals.

Git is an Open Source project covered by the GNU General Public
License version 2 (some parts of it are under different licenses,
compatible with the GPLv2). It was originally written by Linus
Torvalds with help of a group of hackers around the net.

Please read the file [INSTALL][] for installation instructions.

Many Git online resources are accessible from <https://git-scm.com/>
including full documentation and Git related tools.

See [Documentation/gittutorial.txt][] to get started, then see
[Documentation/giteveryday.txt][] for a useful minimum set of commands, and
`Documentation/git-<commandname>.txt` for documentation of each command.
If git has been correctly installed, then the tutorial can also be
read with `man gittutorial` or `git help tutorial`, and the
documentation of each command with `man git-<commandname>` or `git help
<commandname>`.

CVS users may also want to read [Documentation/gitcvs-migration.txt][]
(`man gitcvs-migration` or `git help cvs-migration` if git is
installed).

The user discussion and development of Git take place on the Git
mailing list -- everyone is welcome to post bug reports, feature
requests, comments and patches to git@vger.kernel.org (read
[Documentation/SubmittingPatches][] for instructions on patch submission
and [Documentation/CodingGuidelines][]).

Those wishing to help with error message, usage and informational message
string translations (localization l10) should see [po/README.md][]
(a `po` file is a Portable Object file that holds the translations).

To subscribe to the list, send an email to <git+subscribe@vger.kernel.org>
(see https://subspace.kernel.org/subscribing.html for details). The mailing
list archives are available at <https://lore.kernel.org/git/>,
<https://marc.info/?l=git> and other archival sites.

Issues which are security relevant should be disclosed privately to
the Git Security mailing list <git-security@googlegroups.com>.

The maintainer frequently sends the "What's cooking" reports that
list the current status of various development topics to the mailing
list.  The discussion following them give a good reference for
project status, development direction and remaining tasks.

The name "git" was given by Linus Torvalds when he wrote the very
first version. He described the tool as "the stupid content tracker"
and the name as (depending on your mood):

 - random three-letter combination that is pronounceable, and not
   actually used by any common UNIX command.  The fact that it is a
   mispronunciation of "get" may or may not be relevant.
 - stupid. contemptible and despicable. simple. Take your pick from the
   dictionary of slang.
 - "global information tracker": you're in a good mood, and it actually
   works for you. Angels sing, and a light suddenly fills the room.
 - "goddamn idiotic truckload of sh*t": when it breaks

[INSTALL]: INSTALL
[Documentation/gittutorial.txt]: Documentation/gittutorial.txt
[Documentation/giteveryday.txt]: Documentation/giteveryday.txt
[Documentation/gitcvs-migration.txt]: Documentation/gitcvs-migration.txt
[Documentation/SubmittingPatches]: Documentation/SubmittingPatches
[Documentation/CodingGuidelines]: Documentation/CodingGuidelines
[po/README.md]: po/README.md

# VSI Git Build and Installation Guide

### Overview
The **IA64** system is used to build the VSI Git project for both **IA64** and **X86** architectures.
For the **X86** build, a **cross-compiler** is used, and the build process is managed with **GNU/GNV make**.

---

### Build Preconditions
To verify that the correct versions of **GNV** and **SSL** are installed, execute the following commands:
```bash
$ PROD SHOW PROD *GNV*
$ PROD SHOW PROD *SSL3*
```
Ensure the following versions (or higher) are installed:

- **GNV** *V3.0-2*
- **SSL** *V3.0-18 or later*

### X86 Requirements for *Cross-Build*
To verify that `SYS$LIBRARY:NATTABLES.EXE` is correctly set on your system, execute
the following commands:
```bash
$ MCR AUTHORIZE MODIFY <USERNAME> /CLITABLES=SYS$LIBRARY:NATTABLES.EXE
$ Re-Login
```

### Initialization
To properly initialize the build environment, the following command should be executed
before running the make command:
```bash
$ SET PROCESS/PARSE_STYLE=EXTENDED
$ DEFINE DECC$FILENAME_UNIX_NO_VERSION ENABLE
$ DEFINE DECC$ARGV_PARSE_STYLE ENABLE
$ DEFINE DECC$EFS_CHARSET ENABLE
$ DEFINE OPENSSL "SSL3$INCLUDE:"
$ DEFINE DECC$TEXT_LIBRARY SYS$LIBRARY:SYS$LIB_C.TLB
```

### Additional Initialization for *Cross-Build X86*
```bash
$ DEFINE DECC$TEXT_LIBRARY "X86$LIBRARY:SYS$LIB_C.TLB"
$ @SYS$STARTUP:X86_XTOOLS$SYLOGIN.COM
```

### Build Steps
To run the build procedure and create the installation **kit**, follow these steps:
#### 1. Navigate to Your Git Project Directory
```bash
$ SET DEFAULT <GIT_PROJECT_DIRECTORY>
```
#### 2. Navigate to the VMS Subdirectory
```bash
$ SET DEFAULT [.VMS]
```
#### 3. Run the Build Script
Execute the build script to build the project and create the **kit**.
For the first build, you **must** use the **-C** flag to perform a clean build.
```bash
@BUILDALL.COM <ARCHITECTURE_NAME> <FLAG>
```

---

### Alternative Build Method

You can also build and create the installation **kit** manually **without using** the *BUILDALL.COM* script.
Here are the steps for doing it manually:

#### 1. X86 Systems Specific
For X86 systems, you must change `/CLITABLES` to `SYS$LIBRARY:NATTABLES.EXE`.
```bash
$ MCR AUTHORIZE MODIFY <USER_NAME> /CLITABLES=SYS$LIBRARY:NATTABLES.EXE
$ Re-Login
```
#### 2. Initialization
Before starting the build, make sure you have completed all environment setup commands from the **Initialization** section above.
For **X86 cross-builds**, also perform the steps in **Additional Initialization for *Cross-Build X86***.

#### 3. Navigate to Your Git Project Directory
```bash
$ SET DEFAULT <GIT_PROJECT_DIRECTORY>
```
#### 4. Switch to Bash
```bash
$ @SYS$STARTUP:GNV$SETUP
$! @GNU:[LIB]GNV_SETUP.COM for IA64
$ BASH
```
Within Bash:
```bash
BASH-4.3$ vms/config.sh <platform architecture, native by default>
```
#### 5. Navigate to Build Folder Depending on the architecture, the build folder will vary (*e.g., IA64_build for IA64*):
```bash
BASH-4.3$ cd <build_folder>
```
#### 6. Run the Make Command
```bash
BASH-4.3$ make
```
Exit Bash:
```bash
BASH-4.3$ exit
```

### Restore /CLITABLES After Build X86
To restore the `/CLITABLES`, you can use the following commands:
```bash
$ MCR AUTHORIZE MODIFY <USERNAME> /CLITABLES=DCLTABLES
$ Re-Login
```

### Creating An Installation Kit
- Copy Executables
```bash
$ COPY [.<BUILD_PLATFORM>]*.EXE; [-.VMS.KIT.<BUILD_PLATFORM>]
```
- To Create the Installation Kit for **IA64**
```bash
$ PRODUCT PACKAGE GIT/SOURCE=[-.VMS.KIT.IA64]VSI-I64VMS-GIT-V0244-1B-1.PCSI$DESC /DESTINATION=<PATH_TO_KIT> /OPT=NOCONFIRM /FORMAT=SEQUENTIAL /MATERIAL=<DESTINATION_FOR_FILES...>
```
- To Create the Installation Kit for **X86**
```bash
$ PRODUCT PACKAGE /BASE=X86VMS GIT/SOURCE=[-.VMS.KIT.X86_64]VSI-X86VMS-GIT-V0244-1B-1.PCSI$DESC /DESTINATION=<PATH_TO_KIT> /OPT=NOCONFIRM /FORMAT=SEQUENTIAL /MATERIAL=<DESTINATION_FOR_FILES...>
```

---

### Installation
```bash
$ PRODUCT INSTALL GIT /SOURCE=<PATH WITH KIT>
```

### Remove Product
```bash
$ PRODUCT REMOVE GIT
```

---

### Pre-Requisites for Using VSI Git
Before starting with VSI Git, please complete the following steps:
#### 1. If the CA Certificate is Invalid:
```bash
$ DEFINE GIT_SSL_NO_VERIFY 1
```
#### 2. Set Process Parsing Style to Extended:
```bash
$ SET PROCESS/PARSE_STYLE=EXTENDED
```
#### 3. Set Terminal Inquiry:
```bash
$ SET TERMINAL/INQUIRE
```

### Restrictions
- Repositories and your login directory must be on an **ODS-5** file system.
- If multiple versions of the same file are within the Git directory, it is necessary to purge the directory before using Git commands such as `stash`, `checkout`, `merge`, etc. This helps avoid conflicts or errors during these operations.
- VSI Git currently supports only **Unix-like** paths.

### Performance Notes

For better performance when working with large repositories containing many files, it is recommended to adjust the `core.packedGitWindowSize` configuration value.
Setting this value to **1 MiB** (or **32 MiB**) significantly improves performance.

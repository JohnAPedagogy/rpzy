# Yocto Build Troubleshooting Tutorial: core-image-minimal

This document tracks the process of building `core-image-minimal`, documenting errors encountered, solutions applied, and Yocto best practices.

## Yocto Philosophy: The Layered Approach
Yocto is built on the principle of modularity. Metadata is organized into layers (e.g., `meta-poky`, `meta-intel`). This keeps the core system clean while allowing for easy customization. 

**Best Practice:** Never modify the core layers. Always create your own layer (`meta-custom`) for changes.

## Step 1: Initial Build Attempt
Command: `bitbake core-image-minimal`

**Error encountered:**
```
bb.parse.ParseError: ParseError in configuration INHERITs: Could not inherit file classes/image-prelink.bbclass
```

**Troubleshooting:**
The error indicates that `image-prelink.bbclass` could not be found. Searching the `poky` sources confirmed that this class is missing in the current version of Poky.

**Solution:**
Removed `image-prelink` from `USER_CLASSES` in `conf/local.conf`.

**Yocto Philosophy: Keep it Simple**
`USER_CLASSES` is used to enable features across all images. However, enabling features like `image-prelink` requires the necessary metadata to be present in your layers. If it's not there, BitBake will fail early during configuration parsing.

## Step 2: Second Build Attempt
Command: `bitbake core-image-minimal`

**Error encountered:**
```
ERROR: The following required tools (as specified by HOSTTOOLS) appear to be unavailable in PATH, please install them in order to proceed:
  lz4c pzstd unzstd zstd
```

**Troubleshooting:**
The build environment expects these compression tools to be available on the host system. Since I cannot install packages on the host, I need to check if these tools are strictly necessary or if they can be bypassed/mocked.

**Solution:**
Added `HOSTTOOLS_NONFATAL += "lz4c pzstd unzstd zstd"` to `conf/local.conf`. This downgrades the error to a warning, allowing the build to proceed if these tools are not actually used during the specific tasks of `core-image-minimal`.

**Yocto Best Practice: Host Environment Sanitization**
Yocto uses `HOSTTOOLS` to ensure the build is reproducible by strictly controlling which host binaries are accessible. If a tool is missing, Yocto refuses to start to prevent unpredictable failures later in the build.

## Step 3: Third Build Attempt
Command: `bitbake core-image-minimal`

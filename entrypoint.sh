#!/bin/bash

# Where data will be stored
export MIRROR_DIR='/var/www/html'

# Revisions of each os image, juju agent, and juju gui to keep.  1 = Only keep latest versions/builds
export MAX=1

# Whether to include new minimal image builds
export INCLUDE_MINIMAL=true

export LOG='/var/log/mirror-images.log'

###########################
###### Begin Filters ######
###########################

# The following are simplestreams filters.
# Enclose variable in single quotes and pipe separate multiple values

####### Architectures #######

export ARCHES='amd64'

# Full architecture list
# amd64
# arm64
# armel
# armhf
# i386
# powerpc
# ppc64el
# s390x

####### MAAS #######

# MAAS Images, with the exception of centos, use the codename

export MAAS_RELEASES='focal|xenial|bionic|centos7'
export MAAS_BOOTLOADERS='grub*|pxelinux'
export MAAS_ARCHES='amd64'


####### Ubuntu Releases #######

# For Ubuntu, you may use code names or release numbers for releases
# Usually adequate to versions currently covered under LTS
export RELEASES='focal|xenial|bionic'


####### Non-Ubuntu Releases #######

# Non-Ubuntu releases are grabbed from images.linuxcontainers.org
# See https://us.images.linuxcontainers.org/ or https://uk.images.linuxcontainers.org/ for a full list
# These images are dailys only
# They will not have cloudinit on them, install via add via a tool such as packer

export OTHER_OS_LIST='centos|debian|oracle'
export OTHER_OS_RELEASES='7|stretch'


####### Juju Agent (aka Tools) and GUI #######

# Support may ask you to run proposed or devel to address a bug, so best to have these mirrored.
export AGENT_BUILDS='released|proposed|devel'
export GUI_BUILDS='released|devel'

# Note: Juju GUI only comes in one flavor (a compressed archive)
# so there are no "releases" to specify

export AGENT_RELEASES='focal|xenial|bionic|centos7'

# Juju Agent Releases follows same format as ubuntu cloud images (you can use codename or release number)
# At a minmimum, these should match what you plan to deploy using maas, lxd, and kvm

## juju agent release list:
# 16.04
# 18.04
# 20.04
# centos7

####### FORMAT TYPES #######

# Include files with this in their name/extension
export FTYPE_LIST='gz|xz|squashfs|img|ova'


########################################
# Mirror maas images stable            #
########################################
export KEYRING_FILE=/usr/share/keyrings/ubuntu-cloudimage-keyring.gpg
printf "\n\n\e[1mCalculating download for MAAS Images ($(printf '%s\n' ${MAAS_RELEASES//|/,}))...\e[0m\n"
sstream-mirror --progress --max=${MAX} --keyring=${KEYRING_FILE} https://images.maas.io/ephemeral-v3/stable/ ${MIRROR_DIR}/images.maas.io/ephemeral-v3/stable 'release~('${MAAS_RELEASES}')' 'arch~('${MAAS_ARCHES}')'
printf "Current size (MiB) of MAAS Images: $(du -sm ${MIRROR_DIR}/images.maas.io/ephemeral-v3/daily/ --exclude=bootloaders|awk '{print $1,"("$2")"}')\n"

printf "\n\n\e[1mCalculating download for MAAS Bootloaders ($(printf '%s\n' ${MAAS_BOOTLOADERS//|/,}))...\e[0m\n"
sstream-mirror --progress --max=${MAX} --keyring=${KEYRING_FILE} https://images.maas.io/ephemeral-v3/stable/ ${MIRROR_DIR}/images.maas.io/ephemeral-v3/stable 'os~('${MAAS_BOOTLOADERS}')'
printf "Current size (MiB) of MAAS Bootloaders: $(du -sm ${MIRROR_DIR}/images.maas.io/ephemeral-v3/daily/bootloaders/|awk '{print $1,"("$2")"}')\n"

########################################
# Mirror maas images daily             #
########################################

printf "\n\n\e[1mCalculating download for MAAS Images ($(printf '%s\n' ${MAAS_RELEASES//|/,}))...\e[0m\n"
sstream-mirror --progress --max=${MAX} --keyring=${KEYRING_FILE} https://images.maas.io/ephemeral-v3/daily/ ${MIRROR_DIR}/images.maas.io/ephemeral-v3/daily 'release~('${MAAS_RELEASES}')' 'arch~('${MAAS_ARCHES}')'
printf "Current size (MiB) of MAAS Images: $(du -sm ${MIRROR_DIR}/images.maas.io/ephemeral-v3/daily/ --exclude=bootloaders|awk '{print $1,"("$2")"}')\n"

printf "\n\n\e[1mCalculating download for MAAS Bootloaders ($(printf '%s\n' ${MAAS_BOOTLOADERS//|/,}))...\e[0m\n"
sstream-mirror --progress --max=${MAX} --keyring=${KEYRING_FILE} https://images.maas.io/ephemeral-v3/daily/ ${MIRROR_DIR}/images.maas.io/ephemeral-v3/daily 'os~('${MAAS_BOOTLOADERS}')'
printf "Current size (MiB) of MAAS Bootloaders: $(du -sm ${MIRROR_DIR}/images.maas.io/ephemeral-v3/daily/bootloaders/|awk '{print $1,"("$2")"}')\n"

########################################
# Mirror Ubuntu GA images              #
########################################
printf "\n\n\e[1mCalculating download for Ubuntu Cloud-Images (GA) ($(printf '%s\n' ${RELEASES//|/,}))...\e[0m\n"
sstream-mirror --progress --max=${MAX} --path streams/v1/index.json https://cloud-images.ubuntu.com/releases/ ${MIRROR_DIR}/cloud-images.ubuntu.com/releases/ 'datatype~(image-downloads)' 'release~('${RELEASES}')' 'arch~('${ARCHES}')' 'ftype~('${FTYPE_LIST}')'
printf "Current size (MiB) of Ubuntu Cloud-Images (GA): $(du -sm ${MIRROR_DIR}/cloud-images.ubuntu.com/releases/|awk '{print $1,"("$2")"}')\n"

########################################
# Mirror Ubuntu Daily images           #
########################################
printf "\n\n\e[1mCalculating download for Ubuntu Cloud-Images (Daily) ($(printf '%s\n' ${RELEASES//|/,}))...\e[0m\n"
sstream-mirror --progress --max=${MAX} --path streams/v1/index.json https://cloud-images.ubuntu.com/daily/ ${MIRROR_DIR}/cloud-images.ubuntu.com/daily/ 'datatype~(image-downloads)' 'release~('${RELEASES}')' 'arch~('${ARCHES}')' 'ftype~('${FTYPE_LIST}')'
printf "Current size (MiB) of Ubuntu Cloud-Images (Daily): $(du -sm ${MIRROR_DIR}/cloud-images.ubuntu.com/daily/|awk '{print $1,"("$2")"}')\n"

########################################
# Mirror Ubuntu Minimal images         #
########################################
[[ -n ${INCLUDE_MINIMAL} && ${INCLUDE_MINIMAL} = true ]] && { printf "\n\n\e[1mCalculating download for Ubuntu Minimal (GA)...\e[0m\n";sstream-mirror --progress --max=${MAX} --path streams/v1/index.json https://cloud-images.ubuntu.com/minimal/releases/ ${MIRROR_DIR}/cloud-images.ubuntu.com/minimal/releases/ 'path~(released)' 'datatype~(image-downloads)' 'release~('${RELEASES}')' 'arch~('${ARCHES}')' 'ftype~('${FTYPE_LIST}')'; }
[[ -n ${INCLUDE_MINIMAL} && ${INCLUDE_MINIMAL} = true ]] && { printf "Current size (MiB) of Mininal Ubuntu Cloud-Images (GA): $(du -sm ${MIRROR_DIR}/cloud-images.ubuntu.com/minimal/releases/|awk '{print $1,"("$2")"}')\n" ; }
[[ -n ${INCLUDE_MINIMAL} && ${INCLUDE_MINIMAL} = true ]] && { printf "\n\n\e[1mCalculating download for Ubuntu Minimal (Daily)...\e[0m\n";sstream-mirror --progress --max=${MAX} --path streams/v1/index.json https://cloud-images.ubuntu.com/minimal/daily/ ${MIRROR_DIR}/cloud-images.ubuntu.com/minimal/daily/ 'path~(daily)' 'datatype~(image-downloads)' 'release~('${RELEASES}')' 'arch~('${ARCHES}')' 'ftype~('${FTYPE_LIST}')'; }
[[ -n ${INCLUDE_MINIMAL} && ${INCLUDE_MINIMAL} = true ]] && { printf "Current size (MiB) of Mininal Ubuntu Cloud-Images (Daily): $(du -sm ${MIRROR_DIR}/cloud-images.ubuntu.com/minimal/daily/|awk '{print $1,"("$2")"}')\n" ; }

########################################
# Mirror Non-Ubuntu images             #
########################################
[[ -n ${OTHER_OS_LIST} ]] && { printf "\n\n\e[1mCalculating download for Non-Ubuntu OSes ($(printf '%s\n' ${OTHER_OS_LIST//|/,}))...\e[0m\n";sstream-mirror --progress --max=${MAX} --path streams/v1/index.json https://images.linuxcontainers.org/ ${MIRROR_DIR}/images.linuxcontainers.org/ 'path~('${OTHER_OS_LIST}')' 'release~('${OTHER_OS_RELEASES}')' 'arch~('${ARCHES}')'; }
[[ -n ${OTHER_OS_LIST} ]] && { printf "Current size (MiB) of Non-Ubuntu OSes: $(du -sm ${MIRROR_DIR}/images.linuxcontainers.org/|awk '{print $1,"("$2")"}')\n"; }

########################################
# Mirror Juju Agents                   #
########################################
if [[ -n $(grep -iE '\<released\>' <<< ${AGENT_BUILDS})  ]];then 
	printf "\n\n\e[1mCalculating download for \"released\" build of Juju Agent for $(printf '%s\n' ${RELEASES//|/,})...\e[0m\n"
	sstream-mirror --progress --max=${MAX} --no-verify --path streams/v1/index.json https://streams.canonical.com/juju/tools/ ${MIRROR_DIR}/streams.canonical.com/juju/tools 'content_id~(released)' 'release~('${AGENT_RELEASES}')' 'arch~('${ARCHES}')' 'version~(^2.*)'
	[[ ${DRY_RUN} = true ]] || printf "Current size (MiB) of Juju Agent:Released: $(du -sm ${MIRROR_DIR}/streams.canonical.com/juju/tools/agent --exclude=proposed --exclude=devel|awk '{print $1,"("$2")"}')\n"
	[[ ${DRY_RUN} = true ]] || wget -qO ${MIRROR_DIR}/streams.canonical.com/juju/tools/streams/v1/com.canonical.streams-released-tools.json  https:///streams.canonical.com/juju/tools/streams/v1/com.canonical.streams-released-tools.json
	[[ ${DRY_RUN} = true ]] || wget -qO ${MIRROR_DIR}/streams.canonical.com/juju/tools/streams/v1/index.json https://streams.canonical.com/juju/tools/streams/v1/index.json
fi

if [[ -n $(grep -iE '\<proposed\>' <<< ${AGENT_BUILDS}) ]];then 
	printf "\n\n\e[1mCalculating download for \"proposed\" build of Juju Agent for $(printf '%s\n' ${RELEASES//|/,})...\e[0m\n"
	sstream-mirror --progress --max=${MAX} --no-verify --path streams/v1/index2.json https://streams.canonical.com/juju/tools/ ${MIRROR_DIR}/streams.canonical.com/juju/tools 'content_id~(proposed)' 'release~('${AGENT_RELEASES}')' 'arch~('${ARCHES}')' 'version~(^2.*)'
	[[ ${DRY_RUN} = true ]] || printf "Current size (MiB) of Juju Agent:Proposed: $(du -sm ${MIRROR_DIR}/streams.canonical.com/juju/tools  --exclude=released --exclude=devel|awk '{print $1,"("$2")"}')\n"
	[[ ${DRY_RUN} = true ]] || wget -qO ${MIRROR_DIR}/streams.canonical.com/juju/tools/streams/v1/com.ubuntu.juju:proposed:tools.json https://streams.canonical.com/juju/tools/streams/v1/com.ubuntu.juju:proposed:tools.json
	[[ ${DRY_RUN} = true ]] || wget -qO ${MIRROR_DIR}/streams.canonical.com/juju/tools/streams/v1/index.json https://streams.canonical.com/juju/tools/streams/v1/index.json
	[[ ${DRY_RUN} = true ]] || wget -qO ${MIRROR_DIR}/streams.canonical.com/juju/tools/streams/v1/index2.json https://streams.canonical.com/juju/tools/streams/v1/index2.json 
fi

if [[ -n $(grep -iE '\<devel\>' <<< ${AGENT_BUILDS}) ]];then 
	printf "\n\n\e[1mCalculating download for \"devel\" build of Juju Agent for $(printf '%s\n' ${RELEASES//|/,})...\e[0m\n"
	sstream-mirror --progress --max=${MAX} --no-verify --path streams/v1/index2.json https://streams.canonical.com/juju/tools/ ${MIRROR_DIR}/streams.canonical.com/juju/tools 'content_id~(devel)' 'release~('${AGENT_RELEASES}')' 'arch~('${ARCHES}')' 'version~(^2.*)'
	[[ ${DRY_RUN} = true ]] || printf "Current size (MiB) of Juju Agent:Devel: $(du -sm ${MIRROR_DIR}/streams.canonical.com/juju/tools/  --exclude=released --exclude=proposed|awk '{print $1,"("$2")"}')\n"
	[[ ${DRY_RUN} = true ]] || wget -qO ${MIRROR_DIR}/streams.canonical.com/juju/tools/streams/v1/com.ubuntu.juju:devel:tools.json https://streams.canonical.com/juju/tools/streams/v1/com.ubuntu.juju:devel:tools.json
	[[ ${DRY_RUN} = true ]] || wget -qO ${MIRROR_DIR}/streams.canonical.com/juju/tools/streams/v1/index.json https://streams.canonical.com/juju/tools/streams/v1/index.json
	[[ ${DRY_RUN} = true ]] || wget -qO ${MIRROR_DIR}/streams.canonical.com/juju/tools/streams/v1/index2.json https://streams.canonical.com/juju/tools/streams/v1/index2.json 
fi

########################################
# Mirror Juju GUI                      #
########################################
if [[ -n $(grep -iE '\<released\>' <<< ${GUI_BUILDS}) ]];then 
	printf "\n\n\e[1mCalculating download for Juju GUI for build: \"Released\" ...\e[0m\n"
	sstream-mirror --progress --max=${MAX} --no-verify --path streams/v1/index.json https://streams.canonical.com/juju/gui/ ${MIRROR_DIR}/streams.canonical.com/juju/gui/ 'content_id~(released)' 'juju-version~(2|3)'
	[[ ${DRY_RUN} = true ]] || printf "Current size (MiB) of Juju GUI:Released: $(du -sm ${MIRROR_DIR}/streams.canonical.com/juju/gui/ --exclude=devel|awk '{print $1,"("$2")"}')\n"
	[[ ${DRY_RUN} = true ]] || wget -qO ${MIRROR_DIR}/streams.canonical.com/juju/gui/streams/v1/com.canonical.streams-released-gui.json  https://streams.canonical.com/juju/gui/streams/v1/com.canonical.streams-released-gui.json 
	[[ ${DRY_RUN} = true ]] || wget -qO ${MIRROR_DIR}/streams.canonical.com/juju/gui/streams/v1/index.json https://streams.canonical.com/juju/gui/streams/v1/index.json 
fi

if [[ -n $(grep -iE '\<devel\>' <<< ${GUI_BUILDS}) ]];then 
	printf "\n\n\e[1mCalculating download for Juju GUI for build: \"Devel\" ...\e[0m\n"
	sstream-mirror --progress --max=${MAX} --no-verify --path streams/v1/com.canonical.streams-devel-gui.json https://streams.canonical.com/juju/gui/ ${MIRROR_DIR}/streams.canonical.com/juju/gui/ 'content_id~(devel)' 'juju-version~(2|3)'
	[[ ${DRY_RUN} = true ]] || printf "Current size (MiB) of Juju GUI:Devel: $(du -sm ${MIRROR_DIR}/streams.canonical.com/juju/gui/ --exclude=released|awk '{print $1,"("$2")"}')\n"
	[[ ${DRY_RUN} = true ]] || wget -qO ${MIRROR_DIR}/streams.canonical.com/juju/gui/streams/v1/com.canonical.streams-devel-gui.json  https://streams.canonical.com/juju/gui/streams/v1/com.canonical.streams-devel-gui.json 
	[[ ${DRY_RUN} = true ]] || wget -qO ${MIRROR_DIR}/streams.canonical.com/juju/gui/streams/v1/index.json  https://streams.canonical.com/juju/gui/streams/v1/index.json 
fi

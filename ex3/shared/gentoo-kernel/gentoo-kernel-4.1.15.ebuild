EAPI=5

inherit 

DESCRIPTION="Binary kernel for my awesome Linux distro"
HOMEPAGE="https://noexec.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="sys-kernel/gentoo-sources 
        sys-apps/kmod"
		
RESTRICT="strip"


#user variables:
 Linux_dir="/usr/src/linux"
 OUT_dir=""
 
src_compile()
{
 #unset
 unset ARCH
 cp "${SRC_CONFIG}" k.config || die "could not initialize '.config' file"
 emake -C "${KERNEL_DIR}" O="${PWD}" 

}		
src_install()
{
  # move build dir 
  mkdir -p "${D}""${dirname"${KBUILD_OUT}""  || die "could not create dir to move 'build' directory "
  cp -a "${S}" "${D}${KBUILD_OUT}"
}

pkg_config()
{
 # install the files on real location  
 make -C "${Linux_dir}" O=/usr/src/linux-build install modules_install
}

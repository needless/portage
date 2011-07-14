# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
inherit multilib eutils cmake-utils

MY_PV="${PV//./-}"
MY_PV="${MY_PV/_rc/RC}"
DESCRIPTION="Object-oriented Graphics Rendering Engine"
HOMEPAGE="http://www.ogre3d.org/"
SRC_URI="mirror://sourceforge/${PN}/${PN}_src_v${MY_PV}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+boost +boost-threads cg doc double-precision examples +freeimage +ois poco-threads static-libs test tbb-threads tools +zip"
RESTRICT="test" #139905

RDEPEND="
	media-libs/freetype:2
	virtual/opengl
	virtual/glu
	media-libs/glew
	x11-libs/libXt
	x11-libs/libXaw
	x11-libs/libXrandr
	x11-libs/libX11
	boost? ( dev-libs/boost )
	freeimage? ( media-libs/freeimage )
	cg? ( media-gfx/nvidia-cg-toolkit )
	ois? ( dev-games/ois )
	zip? ( sys-libs/zlib dev-libs/zziplib )
	boost-threads? ( dev-libs/boost )
	tbb-threads? ( dev-cpp/tbb )
	poco-threads? ( dev-libs/poco )"
DEPEND="${RDEPEND}
	x11-proto/xf86vidmodeproto
	dev-util/cmake
	dev-util/pkgconfig
	test? ( dev-util/cppunit )"

S="${WORKDIR}/${PN}_src_v${MY_PV}"

src_prepare() {
	ecvs_clean
	if use examples ; then
		cp -r Samples install-examples || die
		find install-examples \
			-name .keepme \
			-print0 | xargs -0 rm -rf
		find install-examples -type d -print0 | xargs -0 rmdir 2> /dev/null
	fi
}

src_configure() {
	local ogre_dynamic_config ogre_static_config ogre_threads_config

	ogre_dynamic_config="
		$(cmake-utils_use cg OGRE_BUILD_PLUGIN_CG)
		$(cmake-utils_use boost OGRE_USE_BOOST)
		$(cmake-utils_use freeimage OGRE_CONFIG_ENABLE_FREEIMAGE)
		$(cmake-utils_use double-precision OGRE_CONFIG_DOUBLE)
		$(cmake-utils_use test OGRE_BUILD_TESTS)
		$(cmake-utils_use doc OGRE_INSTALL_DOCS)
		$(cmake-utils_use static-libs OGRE_STATIC)
		$(cmake-utils_use tools OGRE_BUILD_TOOLS)
		$(cmake-utils_use zip OGRE_CONFIG_ENABLE_ZIP)
		$(cmake-utils_use examples OGRE_BUILD_SAMPLES)
		$(cmake-utils_use examples OGRE_INSTALL_SAMPLES)
		"
#		-DOGRE_BUILD_SAMPLES=0"


	ogre_static_config="
		-DOGRE_LIB_DIRECTORY=$(get_libdir)
		-DOGRE_CONFIG_ALLOCATOR=2
		-DOGRE_CONFIG_NEW_COMPILERS=1
		-DOGRE_CONFIG_CONTAINERS_USE_CUSTOM_ALLOCATOR=1
		-DOGRE_CONFIG_STRING_USE_CUSTOM_ALLOCATOR=0"


	use cg && [ -d /opt/nvidia-cg-toolkit ] && ogre_dynamic_config+=" -DCg_HOME=/opt/nvidia-cg-toolkit"

	use freeimage && LDFLAGS="$LDFLAGS $(pkg-config --static --libs freeimage)"

	if use boost-threads; then
		einfo "Enabling boost as Threading provider"
		ogre_threads_config=" -DOGRE_CONFIG_THREADS=2 -DOGRE_CONFIG_THREAD_PROVIDER=boost"
	elif use tbb-threads; then
		einfo "Enabling poco as Threading provider"
		ogre_threads_config=" -DOGRE_CONFIG_THREADS=2 -DOGRE_CONFIG_THREAD_PROVIDER=tbb"
	elif use poco-threads; then
		einfo "Enabling tbb as Threading provider"
		ogre_threads_config=" -DOGRE_CONFIG_THREADS=2 -DOGRE_CONFIG_THREAD_PROVIDER=poco"
	else
		ewarn "Threading support is disabled!"
		ogre_threads_config=" -DOGRE_CONFIG_THREADS=0"
	fi

	local mycmakeargs="$ogre_dynamic_config $ogre_static_config $ogre_threads_config"
	CMAKE_BUILD_TYPE="Release"
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	if use static-libs && use freeimage; then
		awk '$0 ~ /^Requires:/  { if (split($0, req, ":") == 2) old_req=req[2] } \
		     $0 !~ /^Requires:/ { print $0 } \
		     END                { print "Requires: freeimage " old_req }' \
			"${D}/usr/$(get_libdir)/pkgconfig/OGRE.pc" > "${D}/usr/$(get_libdir)/pkgconfig/OGRE.pc.new"

		mv "${D}/usr/$(get_libdir)/pkgconfig/OGRE.pc"{.new,}
	fi

	if use doc; then
		cd "${D}/usr/share/OGRE/docs"
		mv api/html/* api/
		rmdir api/html

		dohtml -r api manual vbo-update
		rm -r api manual vbo-update

		dodir "/usr/share/doc/${PF}"
		mv * "${D}/usr/share/doc/${PF}"

		cd "${S}"
		rm -r "${D}/usr/share/OGRE/docs"
	fi

	dodir "/usr/share/OGRE"
	mv "${D}/usr/lib64/OGRE/cmake" "${D}/usr/share/OGRE"
}

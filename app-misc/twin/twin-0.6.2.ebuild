# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
DESCRIPTION="Twin is a text-mode window system similar to the old Borland Turbo IDE environment"
HOMEPAGE="http://sourceforge.net/projects/twin/"
#SRC_URI="http://linux.sns.it/~max/twin/${PN}/${P}.tar.gz"
SRC_URI="http://linuz.sns.it/~max/twin/twin-0.6.2.tar.gz"
LICENSE="|| ( GPL-2 LGPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="ncurses oldgtk unicode X xml"

DEPEND=" X? (	x11-libs/libX11
		oldgtk? ( x11-libx/gtk+:1 )
	)
	ncurses? ( sys-libs/ncurses )
	sys-libs/gpm "
RDEPEND="${DEPEND}"

src_configure() {
	econf \
		$(use_enable unicode -unicode ) \
		$(use_enable ncurses hw-tty-termcap ) \
		$(use_enable oldgtk tt-hw-gtk ) \
		$(use_enable xml tt-hw-xml ) \
		$(use_with X x )
}

src_compile() {
	# The build fails with a parallel make
	emake -j1 || die "emake compile failed"
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die "emake install failed"
	dodoc README BUGS || die
}

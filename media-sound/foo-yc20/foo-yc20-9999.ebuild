# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit subversion

DESCRIPTION="YC-20 organ emulation"
HOMEPAGE="http://code.google.com/p/foo-yc20/"

ESVN_REPO_URI="http://foo-yc20.googlecode.com/svn/trunk/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND=""
DEPEND="media-sound/jack-audio-connection-kit
		>=media-sound/ardour-3.9999[lv2]"

src_compile() {
		emake || die
}

src_install() {
		make DESTDIR="${D}" PREFIX="/usr/" install || die "emake install failed."
}

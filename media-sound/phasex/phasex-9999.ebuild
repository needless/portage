# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit git eutils

DESCRIPTION="Software synthesizer (Phase Harmonic Advanced Synthesis EXperiment)"
HOMEPAGE="https://github.com/grammo/phasex"
EGIT_REPO_URI="https://github.com/grammo/phasex.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="x11-libs/libX11
	media-sound/jack-audio-connection-kit
	media-libs/alsa-lib
	media-libs/libsamplerate
	x11-libs/gtk+:2"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"


src_compile() {
	econf
	emake || die
}


src_install() {
	make DESTDIR="${D}" PREFIX="/usr/" install || die "emake install failed."
	dodoc AUTHORS ChangeLog README TODO doc/ROADMAP
}

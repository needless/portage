# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

MY_P="tacacs+-F${PV}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="An updated version of Cisco's TACACS+ server"
HOMEPAGE="http://www.shrubbery.net/tac_plus/"
SRC_URI="ftp://ftp.shrubbery.net/pub/tac_plus/${MY_P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc"
IUSE="debug finger maxsess tcpd skey static-libs"

DEPEND="skey? ( >=sys-auth/skey-1.1.5-r1 )
	tcpd? ( sys-apps/tcp-wrappers )"
RDEPEND="${DEPEND}"

src_compile() {
	econf \
		$(use_with skey) \
		$(use_with tcpd libwrap) \
		$(use_enable debug) \
		$(use_enable finger) \
		$(use_enable maxsess) \
		$(use_enable static-libs static) \
		|| die "econf failed"

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"
	dodoc CHANGES FAQ

	newinitd "${FILESDIR}/tac_plus.init" tac_plus
	newconfd "${FILESDIR}/tac_plus.confd" tac_plus

	insinto /etc/tac_plus
	newins "${FILESDIR}/tac_plus.conf" tac_plus.conf || die
}

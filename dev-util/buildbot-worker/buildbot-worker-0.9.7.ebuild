# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
PYTHON_COMPAT=( python2_7 python3_5 )

EGIT_REPO_URI="https://github.com/buildbot/buildbot.git"

[[ ${PV} == *9999 ]] && inherit git-r3
inherit readme.gentoo user distutils-r1

DESCRIPTION="BuildBot Slave Daemon"
HOMEPAGE="https://buildbot.net/ https://github.com/buildbot/buildbot https://pypi.python.org/pypi/buildbot-worker"

MY_V="${PV/_p/p}"
MY_P="${PN}-${MY_V}"
[[ ${PV} == *9999 ]] || SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
if [[ ${PV} == *9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~amd64"
fi
IUSE="test"

RDEPEND=">=dev-python/setuptools-21.2.1[${PYTHON_USEDEP}]
	>=dev-python/twisted-17.1.0[${PYTHON_USEDEP}]
	dev-python/future[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}
	test? (
		dev-python/mock[${PYTHON_USEDEP}]
		dev-python/setuptools_trial[${PYTHON_USEDEP}]
	)
"

S="${WORKDIR}/${MY_P}"
[[ ${PV} == *9999 ]] && S=${S}/slave

pkg_setup() {
	enewuser buildbot

	DOC_CONTENTS="The \"buildbot\" user and the \"buildbot_worker\" init script has been added
		to support starting buildbot_worker through Gentoo's init system. To use this,
		set up your build worker following the documentation, make sure the
		resulting directories are owned by the \"buildbot\" user and point
		\"${ROOT}etc/conf.d/buildbot_worker\" at the right location.  The scripts can
		run as a different user if desired. If you need to run more than one
		build worker, just copy the scripts."
}

python_test() {
	distutils_install_for_testing

	esetup.py test || die "Tests failed under ${EPYTHON}"
}

python_install_all() {
	distutils-r1_python_install_all

	doman docs/buildbot-worker.1

	newconfd "${FILESDIR}/buildbot_worker.confd" buildbot_worker
	newinitd "${FILESDIR}/buildbot_worker.initd" buildbot_worker

	readme.gentoo_create_doc
}

pkg_postinst() {
	readme.gentoo_print_elog
}

# install-0.1.sh -- Inital setup script v0.1
# Copyright (C) 2011 Vishwanath Venkataraman (thelinuxguyis@yahoo.co.in)
# This program is relased under GNU GPL Version 3, 29 June 2007
# For conditions of distribution and use, see copyright notice in COPYRIGHT.txt
# This is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY, to the extent permitted by law; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#!/bin/bash
##set -x

## Fetch Gentoo Script s
INSTALL_SCRIPT=(`ls scripts/001*.sh | sort`)

## Run the install script.
for SCRIPT in ${INSTALL_SCRIPT[@]}; do "$SCRIPT" || { echo "$SCRIPT: Failed."; exit 1; } done


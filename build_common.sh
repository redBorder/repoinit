f_ssh_rbrepo() {
	ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@rbrepo.redborder.lan "$@"
}

f_rsync_repo() {
	local LIST="$@"
	rsync -av -e "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" ${LIST} root@rbrepo.redborder.lan:/repos/redBorder
}

f_rsync_iso() {
	local LIST="$@"
	rsync -av -e "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" ${LIST} root@rbrepo.redborder.lan:/isos/redBorder
}

f_updaterepo() {
	local REPODIR=$1
	local count ret

	echo "Updating repo ${REPODIR}"
	count=300
	ret=0
	while : ;do
		if [ ! -e /var/lock/sdk7_createrepo ]; then
			# No lock file, go on
			break
		else
			count=$(($count-1))
			if [ $count -eq 0 ]; then
				# reached final count
				ret=1
				break
			fi
		fi
		# waiting 1 second (max 5 minutes)
		sleep 1
	done
	if [ $ret -eq 0 ]; then
		# it is time to update repo
		touch /var/lock/sdk7_createrepo
		createrepo ${REPODIR}
		rm -f /var/lock/sdk7_createrepo
	else
		echo "Error updating repo ${REPODIR}"
	fi
	return $ret
}

f_rupdaterepo() {
	local REPODIR=/repos/redBorder
	local count ret
	echo "Updating repo ${REPODIR}"
	count=300
	ret=0
	while : ;do
		f_ssh_rbrepo test -e /var/lock/sdk7_createrepo
		if [ $? -ne 0 ]; then
			# No lock file, go on
			break
		else
			count=$(($count-1))
			if [ $count -eq 0 ]; then
				# reached final count
				ret=1
				break
			fi
		fi
		# waiting 1 second (max 5 minutes)
		sleep 1
	done
	if [ $ret -eq 0 ]; then
		# it is time to update repo
		f_ssh_rbrepo touch /var/lock/sdk7_createrepo
		f_ssh_rbrepo createrepo ${REPODIR}
		f_ssh_rbrepo rm -f /var/lock/sdk7_createrepo
	else
		echo "Error updating repo ${REPODIR}"
	fi
	return $ret
}


f_check() {
	# need to check if the packages exist
	local list_of_packages="$@"
	local create_rpms=0
	for package in ${list_of_packages}; do
		if [ -e ${package} ]; then
        		file --mime-type -b ${package} | grep -q "application/x-rpm"
        		if [ $? -ne 0 ]; then
				create_rpms=1
				break
        	        fi
		else
			create_rpms=1
			break
		fi
	done
	return ${create_rpms}
}

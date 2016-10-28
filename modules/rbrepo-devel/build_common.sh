f_ssh_rbrepo() {
	ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@rbrepo.redborder.lan "$@"
}

f_rsync_repo() {
	local LIST="$@"
	rsync -av -e "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" ${LIST} root@rbrepo.redborder.lan:/repos/devel
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
		if [ ! -e /var/lock/rbrepo_createrepo ]; then
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
		touch /var/lock/rbrepo_createrepo
		createrepo ${REPODIR}
		rm -f /var/lock/rbrepo_createrepo
	else
		echo "Error updating repo ${REPODIR}"
	fi
	return $ret
}

f_rupdaterepo() {
	local REPODIR=/repos/devel
	local count ret
	echo "Updating repo ${REPODIR}"
	count=300
	ret=0
	while : ;do
		f_ssh_rbrepo test -e /var/lock/rbrepo_createrepo
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
		f_ssh_rbrepo touch /var/lock/rbrepo_createrepo
		f_ssh_rbrepo createrepo --update ${REPODIR}
		f_ssh_rbrepo rm -f /var/lock/rbrepo_createrepo
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
		f_ssh_rbrepo test -e ${package}
		if [ $? -eq 0 ]; then
        		f_ssh_rbrepo file --mime-type -b ${package} | grep -q "application/x-rpm"
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

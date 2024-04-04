#!/usr/bin/python3

"""distributes an archive to your web servers"""

from fabric.api import env, run, put
from os.path import exists
env.hosts = ["web-02.gwin.tech", 'web-01.gwin.tech']


def do_deploy(archive_path):
    """Push local archieve to remote server """

    archive_file = archive_path.split('/')[-1]
    archive_file_noext = archive_file.split('.')[0]
    remo_releases = '/data/web_static/releases/{}/'.format(archive_file_noext)
    tmp_arch = '/tmp/{}'.format(archive_file)
    repo_cur = '/data/web_static/current'
    if not archive_path or not exists(archive_path.split('/')[0]):
        return False
    try:
        put("{}".format(archive_path), "/tmp/")
        run("mkdir -p {}".format(remo_releases))
        run("tar -xzf {} -C {}".format(tmp_arch, remo_releases))
        run("rm {}".format(tmp_arch))
        run("mv {}web_static/* {}".format(remo_releases, remo_releases))
        run("rm -rf {}web_static".format(remo_releases))
        run("rm -rf {}".format(repo_cur))
        run("ln -s {} {}".format(remo_releases, repo_cur))
        print("New version deployed!")
        return True
    except Exception:
        return False

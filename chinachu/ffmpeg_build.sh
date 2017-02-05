#!/bin/sh

cpu_core=8
enable_h264=1
enable_h265=1
enable_vp8=1
enable_aac=1
enable_mp3=1
enable_ogg=1
enable_opus=1
enable_ass=1

src_dir="$HOME/ffmpeg_sources"
prefix_dir="/usr/local/ffmpeg_build"

export PATH=$prefix_dir/bin:$PATH
export PKG_CONFIG_PATH="$prefix_dir/lib/pkgconfig"
enable_option=""

repo_yasm="git://github.com/yasm/yasm.git"
repo_x264="https://git.videolan.org/git/x264.git"
repo_x265="https://github.com/videolan/x265.git"
repo_aac="git://github.com/mstorsjo/fdk-aac"
repo_opus="git://github.com/xiph/opus.git"
repo_libvpx="https://chromium.googlesource.com/webm/libvpx.git"
repo_libass="https://github.com/libass/libass.git"
repo_ffmpeg="git://github.com/FFmpeg/FFmpeg"

url_autoconf="http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz"
url_lame="http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz"
url_ogg="http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.gz"
url_theora="http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.bz2"
url_vorbis="http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.4.tar.gz"

gcc_ver=`gcc -dumpversion | awk -F. '{print $1}'`

if [ ${gcc_ver} -ge 6 ]; then
    # for x264, libvpx, ffmpeg
    pic_enable="--enable-pic"
    enable_option=${pic_enable}
fi

print_error()
{
    echo "error: $1"
}

run_git()
{
    repo="$1"
    opt="$2"

    dir=${repo##*/}
    dir=${dir%.git}

    if [ -d $dir ]; then
        cd $dir && git pull
        if [ $? -ne 0 ]; then
            print_error "git pull $dir" && exit 1
        fi
    else
        git clone $opt $repo
        if [ $? -ne 0 ]; then
            print_error "git clone $dir" && exit 1
        fi
        cd $dir
    fi
}

run_wget()
{
    url="$1"
    file=${url##*/}
    dir=${file%.tar.*}

    if [ ! -e $file ]; then
        wget -q $url
        if [ $? -ne 0 ]; then
            print_error "wget $file" && exit 1
        fi
    fi

    case $file in
        *.gz)  tar xvzf $file ;;
        *.bz2) tar xvjf $file ;;
    esac

    cd $dir
}

uid=`id | sed 's/uid=\([0-9]\+\)(.\+/\1/'`

if [ $uid -ne 0 ];then
    print_error "not root user"
    exit 1
fi

mkdir -p $src_dir
mkdir -p $prefix_dir

aconf_ver=`LANG=C autoconf -V | head -n 1 | sed -e "s/autoconf (GNU Autoconf) \([0-9]*\)\.\([0-9]*\)/\1\2/"`
if [ $aconf_ver -lt 269 ]; then
    echo "---------- build autoconf ----------"
    run_wget $url_autoconf
    ./configure --prefix="$prefix_dir" --bindir="$prefix_dir/bin"
    make
    make install
    make distclean
fi

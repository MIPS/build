function help() {
cat <<EOF
Invoke ". build/envsetup.sh" from your shell to add the following functions to your environment:
- croot:   Changes directory to the top of the tree.
- m:       Makes from the top of the tree.
- mm:      Builds all of the modules in the current directory.
- mmm:     Builds all of the modules in the supplied directories.
- cgrep:   Greps on all local C/C++ files.
- jgrep:   Greps on all local Java files.
- resgrep: Greps on all local res/*.xml files.
- godir:   Go to the directory containing a file.

Look at the source to view more functions. The complete list is:
EOF
    T=$(gettop)
    local A
    A=""
    for i in `cat $T/build/envsetup.sh | sed -n "/^function /s/function \([a-z_]*\).*/\1/p" | sort`; do
      A="$A $i"
    done
    echo $A
}

# Get the value of a build variable as an absolute path.
function get_abs_build_var()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP." >&2
        return
    fi
    CALLED_FROM_SETUP=true BUILD_SYSTEM=build/core \
      make --no-print-directory -C "$T" -f build/core/config.mk dumpvar-abs-$1
}

# Get the exact value of a build variable.
function get_build_var()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP." >&2
        return
    fi
    CALLED_FROM_SETUP=true BUILD_SYSTEM=build/core \
      make --no-print-directory -C "$T" -f build/core/config.mk dumpvar-$1
}

# check to see if the supplied product is one we can build
function check_product()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP." >&2
        return
    fi
    CALLED_FROM_SETUP=true BUILD_SYSTEM=build/core \
        TARGET_PRODUCT=$1 TARGET_BUILD_VARIANT= \
        TARGET_SIMULATOR= TARGET_BUILD_TYPE= \
        get_build_var TARGET_DEVICE > /dev/null
    # hide successful answers, but allow the errors to show
}

VARIANT_CHOICES=(user userdebug eng)

# check to see if the supplied variant is valid
function check_variant()
{
    for v in ${VARIANT_CHOICES[@]}
    do
        if [ "$v" = "$1" ]
        then
            return 0
        fi
    done
    return 1
}

function setpaths()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return
    fi

    ##################################################################
    #                                                                #
    #              Read me before you modify this code               #
    #                                                                #
    #   This function sets ANDROID_BUILD_PATHS to what it is adding  #
    #   to PATH, and the next time it is run, it removes that from   #
    #   PATH.  This is required so lunch can be run more than once   #
    #   and still have working paths.                                #
    #                                                                #
    ##################################################################

    # out with the old
    if [ -n $ANDROID_BUILD_PATHS ] ; then
        export PATH=${PATH/$ANDROID_BUILD_PATHS/}
    fi

    # and in with the new
    CODE_REVIEWS=
    prebuiltdir=$(getprebuilt)
    local arch=$(gettargetarch)
    if [ $arch = "mips" ]; then
	export ANDROID_EABI_TOOLCHAIN=$prebuiltdir/toolchain/mips-4.3/bin
	export ANDROID_TOOLCHAIN=$ANDROID_EABI_TOOLCHAIN
    fi
    if [ $arch = "arm" ]; then
	export ANDROID_EABI_TOOLCHAIN=$prebuiltdir/toolchain/arm-eabi-4.2.1/bin
	export ANDROID_TOOLCHAIN=$ANDROID_EABI_TOOLCHAIN
    fi
    export ANDROID_QTOOLS=$T/development/emulator/qtools
    export ANDROID_BUILD_PATHS=:$(get_build_var ANDROID_BUILD_PATHS):$ANDROID_QTOOLS:$ANDROID_TOOLCHAIN:$ANDROID_EABI_TOOLCHAIN$CODE_REVIEWS
    export PATH=$PATH$ANDROID_BUILD_PATHS

    unset ANDROID_PRODUCT_OUT
    export ANDROID_PRODUCT_OUT=$(get_abs_build_var PRODUCT_OUT)
    export OUT=$ANDROID_PRODUCT_OUT

    # needed for building linux on MacOS
    # TODO: fix the path
    #export HOST_EXTRACFLAGS="-I "$T/system/kernel_headers/host_include

    # needed for OProfile to post-process collected samples
    export OPROFILE_EVENTS_DIR=$prebuiltdir/oprofile
}

function printconfig()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP." >&2
        return
    fi
    get_build_var report_config
}

function set_stuff_for_environment()
{
    settitle
    setpaths
    set_sequence_number

    # Don't try to do preoptimization until it works better on OSX.
    export DISABLE_DEXPREOPT=true

    export ANDROID_BUILD_TOP=$(gettop)
}

function set_sequence_number()
{
    export BUILD_ENV_SEQUENCE_NUMBER=9
}

function settitle()
{
    if [ "$STAY_OFF_MY_LAWN" = "" ]; then
        local arch=$(gettargetarch)
        local product=$(get_build_var TARGET_PRODUCT)
        local variant=$(get_build_var TARGET_BUILD_VARIANT)
        export PROMPT_COMMAND="echo -ne \"\033]0;[${arch}-${product}-${variant}] ${USER}@${HOSTNAME}: ${PWD}\007\""
    fi
}

case `uname -s` in
    Linux)
        function choosesim()
        {
            echo "Build for the simulator or the device?"
            echo "     1. Device"
            echo "     2. Simulator"
            echo

            export TARGET_SIMULATOR=
            local ANSWER
            while [ -z $TARGET_SIMULATOR ]
            do
                echo -n "Which would you like? [1] "
                if [ -z "$1" ] ; then
                    read ANSWER
                else
                    echo $1
                    ANSWER=$1
                fi
                case $ANSWER in
                "")
                    export TARGET_SIMULATOR=false
                    ;;
                1)
                    export TARGET_SIMULATOR=false
                    ;;
                Device)
                    export TARGET_SIMULATOR=false
                    ;;
                2)
                    export TARGET_SIMULATOR=true
                    ;;
                Simulator)
                    export TARGET_SIMULATOR=true
                    ;;
                *)
                    echo
                    echo "I didn't understand your response.  Please try again."
                    echo
                    ;;
                esac
                if [ -n "$1" ] ; then
                    break
                fi
            done

            set_stuff_for_environment
        }
        ;;
    *)
        function choosesim()
        {
            echo "Only device builds are supported for" `uname -s`
            echo "     Forcing TARGET_SIMULATOR=false"
            echo
            if [ -z "$1" ]
            then
                echo -n "Press enter: "
                read
            fi

            export TARGET_SIMULATOR=false
            set_stuff_for_environment
        }
        ;;
esac

function choosetype()
{
    echo "Build type choices are:"
    echo "     1. release"
    echo "     2. debug"
    echo

    local DEFAULT_NUM DEFAULT_VALUE
    if [ $TARGET_SIMULATOR = "false" ] ; then
        DEFAULT_NUM=1
        DEFAULT_VALUE=release
    else
        DEFAULT_NUM=2
        DEFAULT_VALUE=debug
    fi

    export TARGET_BUILD_TYPE=
    local ANSWER
    while [ -z $TARGET_BUILD_TYPE ]
    do
        echo -n "Which would you like? ["$DEFAULT_NUM"] "
        if [ -z "$1" ] ; then
            read ANSWER
        else
            echo $1
            ANSWER=$1
        fi
        case $ANSWER in
        "")
            export TARGET_BUILD_TYPE=$DEFAULT_VALUE
            ;;
        1)
            export TARGET_BUILD_TYPE=release
            ;;
        release)
            export TARGET_BUILD_TYPE=release
            ;;
        2)
            export TARGET_BUILD_TYPE=debug
            ;;
        debug)
            export TARGET_BUILD_TYPE=debug
            ;;
        *)
            echo
            echo "I didn't understand your response.  Please try again."
            echo
            ;;
        esac
        if [ -n "$1" ] ; then
            break
        fi
    done

    set_stuff_for_environment
}

#
# This function isn't really right:  It chooses a TARGET_PRODUCT
# based on the list of boards.  Usually, that gets you something
# that kinda works with a generic product, but really, you should
# pick a product by name.
#
function chooseproduct()
{
    # Find the makefiles that must exist for a product.
    # Send stderr to /dev/null in case partner isn't present.
    local -a choices
    choices=(`/bin/ls build/target/board/*/BoardConfig.mk vendor/*/*/BoardConfig.mk 2> /dev/null`)

    local choice
    local -a prodlist
    for choice in ${choices[@]}
    do
        # The product name is the name of the directory containing
        # the makefile we found, above.
        prodlist=(${prodlist[@]} `dirname ${choice} | xargs basename`)
    done

    local index=1
    local p
    echo "Product choices are:"
    for p in ${prodlist[@]}
    do
        echo "     $index. $p"
        let "index = $index + 1"
    done


    if [ "x$TARGET_PRODUCT" != x ] ; then
        default_value=$TARGET_PRODUCT
    else
        if [ "$TARGET_SIMULATOR" = true ] ; then
            default_value=sim
        else
            default_value=generic
        fi
    fi

    export TARGET_PRODUCT=
    local ANSWER
    while [ -z "$TARGET_PRODUCT" ]
    do
        echo "You can also type the name of a product if you know it."
        echo -n "Which would you like? [$default_value] "
        if [ -z "$1" ] ; then
            read ANSWER
        else
            echo $1
            ANSWER=$1
        fi

        if [ -z "$ANSWER" ] ; then
            export TARGET_PRODUCT=$default_value
        elif (echo -n $ANSWER | grep -q -e "^[0-9][0-9]*$") ; then
            local poo=`echo -n $ANSWER`
            if [ $poo -le ${#prodlist[@]} ] ; then
                export TARGET_PRODUCT=${prodlist[$(($ANSWER-$_arrayoffset))]}
            else
                echo "** Bad product selection: $ANSWER"
            fi
        else
            if check_product $ANSWER
            then
                export TARGET_PRODUCT=$ANSWER
            else
                echo "** Not a valid product: $ANSWER"
            fi
        fi
        if [ -n "$1" ] ; then
            break
        fi
    done

    set_stuff_for_environment
}

function choosevariant()
{
    echo "Variant choices are:"
    local index=1
    local v
    for v in ${VARIANT_CHOICES[@]}
    do
        # The product name is the name of the directory containing
        # the makefile we found, above.
        echo "     $index. $v"
        index=$(($index+1))
    done

    local default_value=eng
    local ANSWER

    export TARGET_BUILD_VARIANT=
    while [ -z "$TARGET_BUILD_VARIANT" ]
    do
        echo -n "Which would you like? [$default_value] "
        if [ -z "$1" ] ; then
            read ANSWER
        else
            echo $1
            ANSWER=$1
        fi

        if [ -z "$ANSWER" ] ; then
            export TARGET_BUILD_VARIANT=$default_value
        elif (echo -n $ANSWER | grep -q -e "^[0-9][0-9]*$") ; then
            if [ "$ANSWER" -le "${#VARIANT_CHOICES[@]}" ] ; then
                export TARGET_BUILD_VARIANT=${VARIANT_CHOICES[$(($ANSWER-$_arrayoffset))]}
            fi
        else
            if check_variant $ANSWER
            then
                export TARGET_BUILD_VARIANT=$ANSWER
            else
                echo "** Not a valid variant: $ANSWER"
            fi
        fi
        if [ -n "$1" ] ; then
            break
        fi
    done
}

function tapas()
{
    choosecombo
}

function choosecombo()
{
    choosesim $1

    echo
    echo
    choosetype $2

    echo
    echo
    chooseproduct $3

    echo
    echo
    choosevariant $4

    echo
    set_stuff_for_environment
    printconfig
}

# Clear this variable.  It will be built up again when the vendorsetup.sh
# files are included at the end of this file.
unset LUNCH_MENU_CHOICES
function add_lunch_combo()
{
    local new_combo=$1
    local c
    for c in ${LUNCH_MENU_CHOICES[@]} ; do
        if [ "$new_combo" = "$c" ] ; then
            return
        fi
    done
    LUNCH_MENU_CHOICES=(${LUNCH_MENU_CHOICES[@]} $new_combo)
}

# add the default one here
add_lunch_combo generic-eng

# if we're on linux, add the simulator.  There is a special case
# in lunch to deal with the simulator
if [ "$(uname)" = "Linux" ] ; then
    add_lunch_combo simulator
fi

function print_lunch_menu()
{
    local uname=$(uname)
    echo
    echo "You're building on" $uname
    echo
    echo ${LUNCH_MENU_CHOICES[@]}
    echo "Lunch menu... pick a combo:"

    local i=1
    local choice
    for choice in ${LUNCH_MENU_CHOICES[@]}
    do
        echo "     $i. $choice"
        i=$(($i+1))
    done

    echo
}

function lunch()
{
    local answer

    if [ "$1" ] ; then
        answer=$1
    else
        print_lunch_menu
        echo -n "Which would you like? [generic-eng] "
        read answer
    fi

    local selection=

    if [ -z "$answer" ]
    then
        selection=generic-eng
    elif [ "$answer" = "simulator" ]
    then
        selection=simulator
    elif (echo -n $answer | grep -q -e "^[0-9][0-9]*$")
    then
        if [ $answer -le ${#LUNCH_MENU_CHOICES[@]} ]
        then
            selection=${LUNCH_MENU_CHOICES[$(($answer-$_arrayoffset))]}
        fi
    elif (echo -n $answer | grep -q -e "^[^\-][^\-]*-[^\-][^\-]*$")
    then
        selection=$answer
    fi

    if [ -z "$selection" ]
    then
        echo
        echo "Invalid lunch combo: $answer"
        return 1
    fi

    # special case the simulator
    if [ "$selection" = "simulator" ]
    then
        export TARGET_PRODUCT=sim
        export TARGET_BUILD_VARIANT=eng
        export TARGET_SIMULATOR=true
        export TARGET_BUILD_TYPE=debug
    else
        local product=$(echo -n $selection | sed -e "s/-.*$//")
        check_product $product
        if [ $? -ne 0 ]
        then
            echo
            echo "** Don't have a product spec for: '$product'"
            echo "** Do you have the right repo manifest?"
            product=
        fi

        local variant=$(echo -n $selection | sed -e "s/^[^\-]*-//")
        check_variant $variant
        if [ $? -ne 0 ]
        then
            echo
            echo "** Invalid variant: '$variant'"
            echo "** Must be one of ${VARIANT_CHOICES[@]}"
            variant=
        fi

        if [ -z "$product" -o -z "$variant" ]
        then
            echo
            return 1
        fi

        export TARGET_PRODUCT=$product
        export TARGET_BUILD_VARIANT=$variant
        export TARGET_SIMULATOR=false
        export TARGET_BUILD_TYPE=release
    fi # !simulator

    echo

    set_stuff_for_environment
    printconfig
}

function gettop
{
    local TOPFILE=build/core/envsetup.mk
    if [ -n "$TOP" -a -f "$TOP/$TOPFILE" ] ; then
        echo $TOP
    else
        if [ -f $TOPFILE ] ; then
            echo $PWD
        else
            # We redirect cd to /dev/null in case it's aliased to
            # a command that prints something as a side-effect
            # (like pushd)
            local HERE=$PWD
            T=
            while [ \( ! \( -f $TOPFILE \) \) -a \( $PWD != "/" \) ]; do
                cd .. > /dev/null
                T=$PWD
            done
            cd $HERE > /dev/null
            if [ -f "$T/$TOPFILE" ]; then
                echo $T
            fi
        fi
    fi
}

function m()
{
    T=$(gettop)
    if [ "$T" ]; then
        make -C $T $@
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
}

function findmakefile()
{
    TOPFILE=build/core/envsetup.mk
    # We redirect cd to /dev/null in case it's aliased to
    # a command that prints something as a side-effect
    # (like pushd)
    local HERE=$PWD
    T=
    while [ \( ! \( -f $TOPFILE \) \) -a \( $PWD != "/" \) ]; do
        T=$PWD
        if [ -f "$T/Android.mk" ]; then
            echo $T/Android.mk
            cd $HERE > /dev/null
            return
        fi
        cd .. > /dev/null
    done
    cd $HERE > /dev/null
}

function mm()
{
    # If we're sitting in the root of the build tree, just do a
    # normal make.
    if [ -f build/core/envsetup.mk -a -f Makefile ]; then
        make $@
    else
        # Find the closest Android.mk file.
        T=$(gettop)
        local M=$(findmakefile)
        if [ ! "$T" ]; then
            echo "Couldn't locate the top of the tree.  Try setting TOP."
        elif [ ! "$M" ]; then
            echo "Couldn't locate a makefile from the current directory."
        else
            ONE_SHOT_MAKEFILE=$M make -C $T files $@
        fi
    fi
}

function mmm()
{
    T=$(gettop)
    if [ "$T" ]; then
        local MAKEFILE=
        local ARGS=
        local DIR TO_CHOP
        local DASH_ARGS=$(echo "$@" | awk -v RS=" " -v ORS=" " '/^-.*$/')
        local DIRS=$(echo "$@" | awk -v RS=" " -v ORS=" " '/^[^-].*$/')
        for DIR in $DIRS ; do
            DIR=`echo $DIR | sed -e 's:/$::'`
            if [ -f $DIR/Android.mk ]; then
                TO_CHOP=`echo $T | wc -c | tr -d ' '`
                TO_CHOP=`expr $TO_CHOP + 1`
                MFILE=`echo $PWD | cut -c${TO_CHOP}-`
                if [ "$MFILE" = "" ] ; then
                    MFILE=$DIR/Android.mk
                else
                    MFILE=$MFILE/$DIR/Android.mk
                fi
                MAKEFILE="$MAKEFILE $MFILE"
            else
                if [ "$DIR" = snod ]; then
                    ARGS="$ARGS snod"
                elif [ "$DIR" = showcommands ]; then
                    ARGS="$ARGS showcommands"
                else
                    echo "No Android.mk in $DIR."
                fi
            fi
        done
        ONE_SHOT_MAKEFILE="$MAKEFILE" make -C $T $DASH_ARGS files $ARGS
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
}

function croot()
{
    T=$(gettop)
    if [ "$T" ]; then
        cd $(gettop)
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
}

function pid()
{
   local EXE="$1"
   if [ "$EXE" ] ; then
       local PID=`adb shell ps | fgrep $1 | sed -e 's/[^ ]* *\([0-9]*\).*/\1/'`
       echo "$PID"
   else
       echo "usage: pid name"
   fi
}

function gdbclient()
{
   local OUT_ROOT=$(get_abs_build_var PRODUCT_OUT)
   local OUT_SYMBOLS=$(get_abs_build_var TARGET_OUT_UNSTRIPPED)
   local OUT_SO_SYMBOLS=$(get_abs_build_var TARGET_OUT_SHARED_LIBRARIES_UNSTRIPPED)
   local OUT_EXE_SYMBOLS=$(get_abs_build_var TARGET_OUT_EXECUTABLES_UNSTRIPPED)
   local PREBUILTS=$(get_abs_build_var ANDROID_PREBUILTS)
   local ARCH=$(gettargetarch)
   local BUILD_PATHS=$(get_build_var ANDROID_BUILD_PATHS)
   if [ "$OUT_ROOT" -a "$PREBUILTS" ]; then
       local EXE="$1"
       if [ "$EXE" ] ; then
           EXE=$1
       else
           EXE="app_process"
       fi

       local PORT="$2"
       if [ "$PORT" ] ; then
           PORT=$2
       else
           PORT=":5039"
       fi

       local PID
       local PROG="$3"
       if [ "$PROG" ] ; then
           PID=`pid $3`
           adb forward "tcp$PORT" "tcp$PORT"
           adb shell gdbserver $PORT --attach $PID &
           sleep 2
       else
               echo ""
               echo "If you haven't done so already, do this first on the device:"
               echo "    gdbserver $PORT /system/bin/$EXE"
                   echo " or"
               echo "    gdbserver $PORT --attach $PID"
               echo ""
       fi

       echo >|"$OUT_ROOT/gdbclient.cmds" "set solib-absolute-prefix $OUT_SYMBOLS"
       echo >>"$OUT_ROOT/gdbclient.cmds" "set solib-search-path $OUT_SO_SYMBOLS"
       echo >>"$OUT_ROOT/gdbclient.cmds" "target remote $PORT"
       echo >>"$OUT_ROOT/gdbclient.cmds" ""

       if [ $ARCH = "mips" ]; then
           gdb=mips-linux-gnu-gdb
       fi
       if [ $ARCH = "arm" ]; then
           gdb=arm-eabi-gdb
       fi
       $gdb -x "$OUT_ROOT/gdbclient.cmds" "$OUT_EXE_SYMBOLS/$EXE"
   else
       echo "Unable to determine build system output dir."
   fi

}

case `uname -s` in
    Darwin)
        function sgrep()
        {
            find -E . -type f -iregex '.*\.(c|h|cpp|S|java|xml)' -print0 | xargs -0 grep --color -n "$@"
        }

        ;;
    *)
        function sgrep()
        {
            find . -type f -iregex '.*\.\(c\|h\|cpp\|S\|java\|xml\)' -print0 | xargs -0 grep --color -n "$@"
        }
        ;;
esac

function gettargetarch
{
    get_build_var TARGET_ARCH
}

function jgrep()
{
    find . -type f -name "*\.java" -print0 | xargs -0 grep --color -n "$@"
}

function cgrep()
{
    find . -type f -name "*\.c*" -print0 | xargs -0 grep --color -n "$@"
}

function resgrep()
{
    for dir in `find . -name res -type d`; do find $dir -type f -name '*\.xml' -print0 | xargs -0 grep --color -n "$@"; done;
}

case `uname -s` in
    Darwin)
        function mgrep()
        {
            find -E . -type f -iregex '.*/(Makefile|Makefile\..*|.*\.make|.*\.mak|.*\.mk)' -print0 | xargs -0 grep --color -n "$@"
        }

        function treegrep()
        {
            find -E . -type f -iregex '.*\.(c|h|cpp|S|java|xml)' -print0 | xargs -0 grep --color -n -i "$@"
        }

        ;;
    *)
        function mgrep()
        {
            find . -regextype posix-egrep -iregex '(.*\/Makefile|.*\/Makefile\..*|.*\.make|.*\.mak|.*\.mk)' -type f -print0 | xargs -0 grep --color -n "$@"
        }

        function treegrep()
        {
            find . -regextype posix-egrep -iregex '.*\.(c|h|cpp|S|java|xml)' -type f -print0 | xargs -0 grep --color -n -i "$@"
        }

        ;;
esac

function getprebuilt
{
    get_abs_build_var ANDROID_PREBUILTS
}

function tracedmdump()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return
    fi
    local prebuiltdir=$(getprebuilt)
    local arch=$(gettargetarch)
    local KERNEL=$T/prebuilt/android-$arch/kernel/vmlinux-qemu

    local TRACE=$1
    if [ ! "$TRACE" ] ; then
        echo "usage:  tracedmdump  tracename"
        return
    fi

    if [ ! -r "$KERNEL" ] ; then
        echo "Error: cannot find kernel: '$KERNEL'"
        return
    fi

    local BASETRACE=$(basename $TRACE)
    if [ "$BASETRACE" = "$TRACE" ] ; then
        TRACE=$ANDROID_PRODUCT_OUT/traces/$TRACE
    fi

    echo "post-processing traces..."
    rm -f $TRACE/qtrace.dexlist
    post_trace $TRACE
    if [ $? -ne 0 ]; then
        echo "***"
        echo "*** Error: malformed trace.  Did you remember to exit the emulator?"
        echo "***"
        return
    fi
    echo "generating dexlist output..."
    /bin/ls $ANDROID_PRODUCT_OUT/system/framework/*.jar $ANDROID_PRODUCT_OUT/system/app/*.apk $ANDROID_PRODUCT_OUT/data/app/*.apk 2>/dev/null | xargs dexlist > $TRACE/qtrace.dexlist
    echo "generating dmtrace data..."
    q2dm -r $ANDROID_PRODUCT_OUT/symbols $TRACE $KERNEL $TRACE/dmtrace || return
    echo "generating html file..."
    dmtracedump -h $TRACE/dmtrace >| $TRACE/dmtrace.html || return
    echo "done, see $TRACE/dmtrace.html for details"
    echo "or run:"
    echo "    traceview $TRACE/dmtrace"
}

# communicate with a running device or emulator, set up necessary state,
# and run the hat command.
function runhat()
{
    # process standard adb options
    local adbTarget=""
    if [ $1 = "-d" -o $1 = "-e" ]; then
        adbTarget=$1
        shift 1
    elif [ $1 = "-s" ]; then
        adbTarget="$1 $2"
        shift 2
    fi
    local adbOptions=${adbTarget}
    echo adbOptions = ${adbOptions}

    # runhat options
    local targetPid=$1
    local outputFile=$2

    if [ "$targetPid" = "" ]; then
        echo "Usage: runhat [ -d | -e | -s serial ] target-pid [output-file]"
        return
    fi

    # confirm hat is available
    if [ -z $(which hat) ]; then
        echo "hat is not available in this configuration."
        return
    fi

    adb ${adbOptions} shell >/dev/null mkdir /data/misc
    adb ${adbOptions} shell chmod 777 /data/misc

    # send a SIGUSR1 to cause the hprof dump
    echo "Poking $targetPid and waiting for data..."
    adb ${adbOptions} shell kill -10 $targetPid
    echo "Press enter when logcat shows \"hprof: heap dump completed\""
    echo -n "> "
    read

    local availFiles=( $(adb ${adbOptions} shell ls /data/misc | grep '^heap-dump' | sed -e 's/.*heap-dump-/heap-dump-/' | sort -r | tr '[:space:][:cntrl:]' ' ') )
    local devFile=/data/misc/${availFiles[0]}
    local localFile=/tmp/$$-hprof

    echo "Retrieving file $devFile..."
    adb ${adbOptions} pull $devFile $localFile

    adb ${adbOptions} shell rm $devFile

    echo "Running hat on $localFile"
    echo "View the output by pointing your browser at http://localhost:7000/"
    echo ""
    hat $localFile
}

function getbugreports()
{
    local reports=(`adb shell ls /sdcard/bugreports | tr -d '\r'`)

    if [ ! "$reports" ]; then
        echo "Could not locate any bugreports."
        return
    fi

    local report
    for report in ${reports[@]}
    do
        echo "/sdcard/bugreports/${report}"
        adb pull /sdcard/bugreports/${report} ${report}
        gunzip ${report}
    done
}

function startviewserver()
{
    local port=4939
    if [ $# -gt 0 ]; then
            port=$1
    fi
    adb shell service call window 1 i32 $port
}

function stopviewserver()
{
    adb shell service call window 2
}

function isviewserverstarted()
{
    adb shell service call window 3
}

function smoketest()
{
    if [ ! "$ANDROID_PRODUCT_OUT" ]; then
        echo "Couldn't locate output files.  Try running 'lunch' first." >&2
        return
    fi
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP." >&2
        return
    fi

    (cd "$T" && mmm tests/SmokeTest) &&
      adb uninstall com.android.smoketest > /dev/null &&
      adb uninstall com.android.smoketest.tests > /dev/null &&
      adb install $ANDROID_PRODUCT_OUT/data/app/SmokeTestApp.apk &&
      adb install $ANDROID_PRODUCT_OUT/data/app/SmokeTest.apk &&
      adb shell am instrument -w com.android.smoketest.tests/android.test.InstrumentationTestRunner
}

# simple shortcut to the runtest command
function runtest()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP." >&2
        return
    fi
    (cd "$T" && development/tools/runtest $@)
}

# simple shortcut to the runtest.py command
function runtest_py()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP." >&2
        return
    fi
    (cd "$T" && development/testrunner/runtest.py $@)
}

function godir () {
    if [[ -z "$1" ]]; then
        echo "Usage: godir <regex>"
        return
    fi
    if [[ ! -f $T/filelist ]]; then
        echo -n "Creating index..."
        (cd $T; find . -wholename ./out -prune -o -type f > filelist)
        echo " Done"
        echo ""
    fi
    local lines
    lines=($(grep "$1" $T/filelist | sed -e 's/\/[^/]*$//' | sort | uniq)) 
    if [[ ${#lines[@]} = 0 ]]; then
        echo "Not found"
        return
    fi
    local pathname
    local choice
    if [[ ${#lines[@]} > 1 ]]; then
        while [[ -z "$pathname" ]]; do
            local index=1
            local line
            for line in ${lines[@]}; do
                printf "%6s %s\n" "[$index]" $line
                index=$(($index + 1)) 
            done
            echo
            echo -n "Select one: "
            unset choice
            read choice
            if [[ $choice -gt ${#lines[@]} || $choice -lt 1 ]]; then
                echo "Invalid choice"
                continue
            fi
            pathname=${lines[$(($choice-$_arrayoffset))]}
        done
    else
        # even though zsh arrays are 1-based, $foo[0] is an alias for $foo[1]
        pathname=${lines[0]}
    fi
    cd $T/$pathname
}

# determine whether arrays are zero-based (bash) or one-based (zsh)
_xarray=(a b c)
if [ -z "${_xarray[${#_xarray[@]}]}" ]
then
    _arrayoffset=1
else
    _arrayoffset=0
fi
unset _xarray

# Execute the contents of any vendorsetup.sh files we can find.
for f in `/bin/ls vendor/*/vendorsetup.sh 2> /dev/null`
do
    echo "including $f"
    . $f
done
unset f

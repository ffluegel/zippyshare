#!/bin/bash
# @Description: zippyshare.com file download script
# @Author: Live2x
# @URL: https://github.com/ffluegel/zippyshare
# @Version: 201808150001
# @Date: 2018-08-15
# @Usage: ./zippyshare.sh url

declare OUTDIR
if [ -d "${2}" ]
then
    OUTDIR=${2}
    length=${#OUTDIR}
    last_char=${OUTDIR:length-1:1}
    [[ $last_char != "/" ]] && OUTDIR="$OUTDIR/"; :
    echo File will be saved to $OUTDIR
fi

if [ -z "${1}" ]
then
    echo "usage: ${0} url"
    echo "batch usage: ${0} url-list.txt"
    echo "url-list.txt is a file that contains one zippyshare.com url per line"
    exit
fi

function zippydownload()
{
    prefix="$( echo -n "${url}" | cut -c "11,12,31-38" | sed -e 's/[^a-zA-Z0-9]//g' )"
    cookiefile="${prefix}-cookie.tmp"
    infofile="${prefix}-info.tmp"

    # loop that makes sure the script actually finds a filename
    filename=""
    retry=0
    while [ -z "${filename}" -a ${retry} -lt 10 ]
    do
        let retry+=1
        rm -f "${cookiefile}" 2> /dev/null
        rm -f "${infofile}" 2> /dev/null
        curl -s -c "${cookiefile}" -o "${infofile}" -L "${url}"
        filename="$( cat "${infofile}" | grep "/d/" | cut -d'/' -f5 | cut -d'"' -f1 | grep -o "[^ ]\+\(\+[^ ]\+\)*" )"
    done

    if [ "${retry}" -ge 10 ]
    then
        echo "could not download file from ${url}"
        rm -f "${cookiefile}" 2> /dev/null
        rm -f "${infofile}" 2> /dev/null
        return 1
    fi

    # Get cookie
    if [ -f "${cookiefile}" ]
    then
        jsessionid="$( cat "${cookiefile}" | grep "JSESSIONID" | cut -f7)"
    else
        echo "can't find cookie file for ${prefix}"
        exit 1
    fi

    if [ -f "${infofile}" ]
    then
        # Get url algorithm
        dlbutton="$( grep 'getElementById..dlbutton...href' "${infofile}" | grep -oE '\([0-9].*\)' )"
        if [ -n "${dlbutton}" ]
        then
           algorithm="${dlbutton}"
        else
           echo "could not get zippyshare url algorithm"
           exit 1
        fi

        a="$( echo $(( ${algorithm} )) )"
        # Get ref, server, id
        ref="$( cat "${infofile}" | grep 'property="og:url"' | cut -d'"' -f4 | grep -o "[^ ]\+\(\+[^ ]\+\)*" )"

        server="$( echo "${ref}" | cut -d'/' -f3 )"

        id="$( echo "${ref}" | cut -d'/' -f5 )"
    else
        echo "can't find info file for ${prefix}"
        exit 1
    fi

    # Build download url
    dl="https://${server}/d/${id}/${a}/${filename}"

    # Set browser agent
    agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36"

    echo "${filename}"

    # Start download file
    curl -# -A "${agent}" -e "${ref}" -H "Cookie: JSESSIONID=${jsessionid}" -C - "${dl}" -o "${OUTDIR}${filename}"

    rm -f "${cookiefile}" 2> /dev/null
    rm -f "${infofile}" 2> /dev/null
}

if [ -f "${1}" ]
then
    if [[ ${1} == *".dlc"* ]];
    then
        decrypt-dlc ${1}
        for url in $( cat urls.txt | grep -i 'zippyshare.com' )
        do
            zippydownload "${url}"
        done
        rm urls.txt
    else
        for url in $( cat "${1}" | grep -i 'zippyshare.com' )
        do
            zippydownload "${url}"
        done
    fi
else
    url="${1}"
    zippydownload "${url}"
fi

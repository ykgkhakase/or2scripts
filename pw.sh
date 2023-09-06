#!/bin/bash
# vim: set ts=2 sw=2 sts=0:

function IsNumericNumber() {
  local v=$1

	if [ -n "$v" ] && [ "$v" -eq "$v" ] 2>/dev/null
	then
  	#number
		true
		return
	else
  	#not a number
		false
		return
	fi
}

function OneStrReplaceRandomly(){
  local str=$1
  local len=$(echo $str | wc -m)
  local a2=$2
  local org_len=$len

  local r
  let len=$len-2
  let r=$RANDOM%$len+1

  #echo "[verbose mode] $r/$org_len " >&2
  #echo "[verbose mode] ${str:0:$r-1}" >&2
  #echo "[verbose mode] $a2" >&2
  #echo "[verbose mode] ${str:$r}" >&2
  echo ${str:0:$r-1}${a2}${str:$r}
}

function InsertSeparatorForString(){
  local str=$1
  local sep=$2
  local num=$3
  local len=$(echo $str | wc -m)
  local a

	let num=$num+1
  let len=$len-2
  
  local rt=''
  
  local cnt=0
  for i in $(seq 0 $len)
  do
    let cnt++
    let a=$cnt%$num
    if [ $i -gt 0 ] && [ $a -eq 0 ]
    then
      #echo "$i: $sep"
      rt=$(echo "$rt$sep")
    else
      #echo "$i: ${str:$i:1}"
      rt=$(echo "$rt${str:$i:1}")
    fi
  done

  echo $rt
}


function Usage(){
  cat<<EOT 
 Usage : $0 (options) [pw length]
 -a : add a sharp to candidates of the PW string.
 -d : add a dollar to candidates of the PW string.
 -s N : add hypenations for each N(>0) step.
 -v   : show pocess of the generation. (verbose mode)
 -h   : show this help.
EOT
  exit 0
}

FLAG_A=0
FLAG_D=0
FLAG_V=0
OPT_S=0

while getopts ads:hv OPT
do
    case $OPT in
        a)  FLAG_A=1
            ;;
        d)  FLAG_D=1
            ;;
        v)  FLAG_V=1
            ;;
        s)  OPT_S=$OPTARG
            ;;
        h) Usage
            ;;
        \?) Usage
            ;;
    esac
done

shift $((OPTIND - 1))

if [ $# -eq 0 ]
then
  Usage
fi

PwLength=$1
if ! IsNumericNumber $PwLength || [ $PwLength -le 0 ]
then
	echo "$PwLength is not integer or smaller than 0." >&2
  exit 1
fi


if ! [ -e /dev/urandom ]
then
  echo "urandom error" >&2
fi

MasterString='0-9a-zA-Z'
if [ $FLAG_D -gt 0 ]
then
  MasterString="$MasterString"'$'
fi

if [ $FLAG_A -gt 0 ]
then
  MasterString="$MasterString"'#'
fi


RawPwString=$(cat /dev/urandom | tr -dc $MasterString | fold -w $PwLength | head -n 1)


if [ $FLAG_V -ne 0 ]
then
  echo "[verbose mode] 0: $MasterString"
fi

if [ $FLAG_V -ne 0 ]
then
  echo "[verbose mode] 1: $RawPwString"
fi

# ensure at least one dollar.
if [ $FLAG_D -gt 0 ] 
then
	echo $RawPwString | grep '\$'  > /dev/null
  if [ $? -eq 1 ]
  then
    if [ $FLAG_V -ne 0 ]; then echo "[verbose mode] 2.1 ensure $"; fi
		RawPwString=$(OneStrReplaceRandomly $RawPwString '$')
  fi
fi

# ensure at least one sharp.
if [ $FLAG_A -gt 0 ] 
then
	echo $RawPwString | grep '\#'  > /dev/null
  if [ $? -eq 1 ]
  then
    if [ $FLAG_V -ne 0 ]; then echo "[verbose mode] 2.1 ensure #"; fi
		RawPwString=$(OneStrReplaceRandomly $RawPwString '#')
  fi
fi


if [ $FLAG_V -ne 0 ]
then
  echo "[verbose mode] 2: $RawPwString"
fi

# output

if [ $OPT_S -gt 0 ]
then
  InsertSeparatorForString $RawPwString "-" $OPT_S
else
  echo $RawPwString
fi


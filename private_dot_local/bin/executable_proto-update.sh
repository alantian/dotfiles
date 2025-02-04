#!/usr/bin/env bash

echo "Install/upgrade proto"

PROTO="$HOME/.proto/bin/proto"

if [ -f $PROTO ] ; then
  $PROTO upgrade
else
  bash <(curl -fsSL https://moonrepo.dev/install/proto.sh) --no-profile --yes
fi


echo "Install/upgrade proto's tools"

$PROTO install python
$PROTO install node
$PROTO install pnpm
$PROTO install ruby
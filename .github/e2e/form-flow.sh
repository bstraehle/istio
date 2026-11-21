#!/usr/bin/env bash
# Adds, updates, and deletes a record through the MVC app's forms (with
# antiforgery token and cookie), so the mvc-app -> rest-api authorization
# policy is exercised for POST, PUT, and DELETE.
# Usage: form-flow.sh <base-url>
set -euo pipefail
base=$1
jar=$(mktemp)
trap 'rm -f "$jar"' EXIT

submit() { # <form page> <form action> <field>...
  local page token
  page=$(curl -fsS -c "$jar" -b "$jar" "$base/Demo/$1")
  token=$(grep -o 'name="__RequestVerificationToken" type="hidden" value="[^"]*"' <<<"$page" | sed 's/.*value="//; s/"$//')
  test -n "$token"
  local args=()
  for field in "${@:3}"; do args+=(--data-urlencode "$field"); done
  code=$(curl -sS -o /dev/null -w '%{http_code}' -c "$jar" -b "$jar" -X POST "$base/Demo/$2" \
    --data-urlencode "__RequestVerificationToken=$token" "${args[@]}")
  echo "$2 -> $code"
  test "$code" = 302
}

list() { curl -fsS "$base/Demo/List"; }

submit Add AddObject Id=77 Name=Seventy-seven
list | grep -q '>Seventy-seven<'
submit Update/77 UpdateObject Id=77 Name=Renamed
list | grep -q '>Renamed<'
submit Delete/77 DeleteObject Id=77 Name=Renamed
! list | grep -q '>77<'
echo "OK add, update, and delete"

#!/usr/bin/env bash
if [ $# -ne 1 ]; then
  echo "Использование: $0 <имя_сервиса>" >&2
  exit 2
fi

SERVICE=${1%.service}
SYSLOG=/var/log/syslog
RC=0

if ! command -v systemctl >/dev/null 2>&1; then
  echo "systemctl не найден: скрипт работает только на хосте с systemd" >&2
  exit 3
fi

if ! systemctl list-unit-files "${SERVICE}.service" --no-legend 2>/dev/null | grep -q .; then
  echo "Сервис ${SERVICE} не найден" >&2
  exit 3
fi

STATE=$(systemctl is-active "$SERVICE")
echo "Сервис ${SERVICE}: ${STATE}"

if [ "$STATE" != "active" ]; then
  RC=1
  echo "--- последние 10 строк журнала ${SERVICE} ---"
  journalctl -u "$SERVICE" -n 10 --no-pager
fi

if [ ! -r "$SYSLOG" ]; then
  echo "Нет доступа к ${SYSLOG}" >&2
elif [ ! -s "$SYSLOG" ]; then
  echo "${SYSLOG} пуст"
elif ! head -n 1 "$SYSLOG" | grep -qE '^[0-9]{4}-[0-9]{2}-'; then
  echo "Формат даты в ${SYSLOG} не ISO, подсчёт ошибок пропущен"
else
  SINCE=$(date -d '1 hour ago' '+%Y-%m-%dT%H:%M:%S')
  COUNT=$(grep -iE 'error|fail|critical' "$SYSLOG" | awk -v since="$SINCE" '$1 >= since {n++} END {print n+0}')
  echo "Ошибок за последний час: ${COUNT}"
fi

exit "$RC"

script=$(realpath "0")
script_path=$(dirname "$script")
source ${script_path}/common.sh

# shellcheck disable=SC2034
component=user
# shellcheck disable=SC2034
schema_setup=mongo
func_nodejs


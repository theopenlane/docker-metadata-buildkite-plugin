#!/usr/bin/env bats

load "$BATS_PLUGIN_PATH/load.bash"

export BUILDKITE_REPO="test-org/test-repo"
export BUILDKITE_COMMIT="12345"
export BUILDKITE_PLUGIN_DOCKER_METADATA_DEBUG=true

# Uncomment the following line to debug stub failures
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

@test "Creates tags and labels for one image" {
  export BUILDKITE_PLUGIN_DOCKER_METADATA_IMAGES_0="foo/bar"

  # We can't use bats' `run` function because it executes in a subshell
  # and we'll loose the environment variables.
  run "$PWD/hooks/environment"

  assert_success
  assert_output --regexp "DOCKER_METADATA_DIR: '.*'"
  local dir=$(echo "$output" | sed -n "s/.*DOCKER_METADATA_DIR: '\(.*\)'/\1/p")
  assert [ -n "$dir" ]
  assert [ -d "$dir" ]
  assert [ -f "$dir/labels" ]
  assert [ -f "$dir/tags" ]

  # Check tags
  assert grep -E "^foo/bar:$BUILDKITE_COMMIT$" "$dir/tags"

  # Check labels
  assert grep -E "^org.opencontainers.image.source=$BUILDKITE_REPO$" "$dir/labels"
  assert grep -E "^org.opencontainers.image.revision=$BUILDKITE_COMMIT$" "$dir/labels"
  assert grep -E "^org.opencontainers.image.created=.*$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.title=.*$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.licenses=.*$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.vendor=.*$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.authors=.*$" "$dir/labels"

  # When no buildkite tag (or git tag) is available, the version is the commit.
  assert grep -E "^org.opencontainers.image.version=$BUILDKITE_COMMIT$" "$dir/labels"

  # Cleanup
  rm -r "$dir"
}

@test "Creates tags and labels for multiple images" {
  export BUILDKITE_PLUGIN_DOCKER_METADATA_IMAGES_0="foo/bar"
  export BUILDKITE_PLUGIN_DOCKER_METADATA_IMAGES_1="beer/tacos"
  export BUILDKITE_PLUGIN_DOCKER_METADATA_IMAGES_2="whiskey/steak"
  export BUILDKITE_PLUGIN_DOCKER_METADATA_IMAGES_3="mezcal/life"

  # We can't use bats' `run` function because it executes in a subshell
  # and we'll loose the environment variables.
  run "$PWD/hooks/environment"

  assert_success
  assert_output --regexp "DOCKER_METADATA_DIR: '.*'"
  local dir=$(echo "$output" | sed -n "s/.*DOCKER_METADATA_DIR: '\(.*\)'/\1/p")
  assert [ -n "$dir" ]
  assert [ -d "$dir" ]
  assert [ -f "$dir/labels" ]
  assert [ -f "$dir/tags" ]

  # Check tags
  assert grep -E "^foo/bar:$BUILDKITE_COMMIT$" "$dir/tags"
  assert grep -E "^beer/tacos:$BUILDKITE_COMMIT$" "$dir/tags"
  assert grep -E "^whiskey/steak:$BUILDKITE_COMMIT$" "$dir/tags"
  assert grep -E "^mezcal/life:$BUILDKITE_COMMIT$" "$dir/tags"

  # Check labels
  assert grep -E "^org.opencontainers.image.source=$BUILDKITE_REPO$" "$dir/labels"
  assert grep -E "^org.opencontainers.image.revision=$BUILDKITE_COMMIT$" "$dir/labels"
  assert grep -E "^org.opencontainers.image.created=.*$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.title=.*$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.licenses=.*$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.vendor=.*$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.authors=.*$" "$dir/labels"

  # Cleanup
  rm -r "$dir"
}

@test "Creates image with title label" {
  export BUILDKITE_PLUGIN_DOCKER_METADATA_IMAGES_0="foo/bar"
  export BUILDKITE_PLUGIN_DOCKER_METADATA_TITLE="my title"

  # We can't use bats' `run` function because it executes in a subshell
  # and we'll loose the environment variables.
  run "$PWD/hooks/environment"

  assert_success
  assert_output --regexp "DOCKER_METADATA_DIR: '.*'"
  local dir=$(echo "$output" | sed -n "s/.*DOCKER_METADATA_DIR: '\(.*\)'/\1/p")
  assert [ -n "$dir" ]
  assert [ -d "$dir" ]
  assert [ -f "$dir/labels" ]
  assert [ -f "$dir/tags" ]

  # Check tags
  assert grep -E "^foo/bar:$BUILDKITE_COMMIT$" "$dir/tags"

  # Check labels
  assert grep -E "^org.opencontainers.image.source=$BUILDKITE_REPO$" "$dir/labels"
  assert grep -E "^org.opencontainers.image.revision=$BUILDKITE_COMMIT$" "$dir/labels"
  assert grep -E "^org.opencontainers.image.created=.*$" "$dir/labels"
  assert grep -E "^org.opencontainers.image.title=$BUILDKITE_PLUGIN_DOCKER_METADATA_TITLE" "$dir/labels"
  refute grep -E "^org.opencontainers.image.licenses=.*$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.vendor=.*$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.authors=.*$" "$dir/labels"

  # Cleanup
  rm -r "$dir"
}

@test "Creates image with licenses label" {
  export BUILDKITE_PLUGIN_DOCKER_METADATA_IMAGES_0="foo/bar"
  export BUILDKITE_PLUGIN_DOCKER_METADATA_LICENSES="Apache-2.0,MIT"

  # We can't use bats' `run` function because it executes in a subshell
  # and we'll loose the environment variables.
  run "$PWD/hooks/environment"

  assert_success
  assert_output --regexp "DOCKER_METADATA_DIR: '.*'"
  local dir=$(echo "$output" | sed -n "s/.*DOCKER_METADATA_DIR: '\(.*\)'/\1/p")
  assert [ -n "$dir" ]
  assert [ -d "$dir" ]
  assert [ -f "$dir/labels" ]
  assert [ -f "$dir/tags" ]

  # Check tags
  assert grep -E "^foo/bar:$BUILDKITE_COMMIT$" "$dir/tags"

  # Check labels
  assert grep -E "^org.opencontainers.image.source=$BUILDKITE_REPO$" "$dir/labels"
  assert grep -E "^org.opencontainers.image.revision=$BUILDKITE_COMMIT$" "$dir/labels"
  assert grep -E "^org.opencontainers.image.created=.*$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.title=.*$" "$dir/labels"
  assert grep -E "^org.opencontainers.image.licenses=$BUILDKITE_PLUGIN_DOCKER_METADATA_LICENSES$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.vendor=.*$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.authors=.*$" "$dir/labels"

  # Cleanup
  rm -r "$dir"
}

@test "Creates image with vendor label" {
  export BUILDKITE_PLUGIN_DOCKER_METADATA_IMAGES_0="foo/bar"
  export BUILDKITE_PLUGIN_DOCKER_METADATA_VENDOR="my vendor"

  # We can't use bats' `run` function because it executes in a subshell
  # and we'll loose the environment variables.
  run "$PWD/hooks/environment"

  assert_success
  assert_output --regexp "DOCKER_METADATA_DIR: '.*'"
  local dir=$(echo "$output" | sed -n "s/.*DOCKER_METADATA_DIR: '\(.*\)'/\1/p")
  assert [ -n "$dir" ]
  assert [ -d "$dir" ]
  assert [ -f "$dir/labels" ]
  assert [ -f "$dir/tags" ]

  # Check tags
  assert grep -E "^foo/bar:$BUILDKITE_COMMIT$" "$dir/tags"

  # Check labels
  assert grep -E "^org.opencontainers.image.source=$BUILDKITE_REPO$" "$dir/labels"
  assert grep -E "^org.opencontainers.image.revision=$BUILDKITE_COMMIT$" "$dir/labels"
  assert grep -E "^org.opencontainers.image.created=.*$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.title=.*$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.licenses=.*$" "$dir/labels"
  assert grep -E "^org.opencontainers.image.vendor=$BUILDKITE_PLUGIN_DOCKER_METADATA_VENDOR$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.authors=.*$" "$dir/labels"

  # Cleanup
  rm -r "$dir"
}

@test "Creates image with authors label (based on teams)" {
  export BUILDKITE_PLUGIN_DOCKER_METADATA_IMAGES_0="foo/bar"
  export BUILDKITE_BUILD_CREATOR_TEAMS="security-eng:foo:equinix-metal"

  # We can't use bats' `run` function because it executes in a subshell
  # and we'll loose the environment variables.
  run "$PWD/hooks/environment"

  assert_success
  assert_output --regexp "DOCKER_METADATA_DIR: '.*'"
  local dir=$(echo "$output" | sed -n "s/.*DOCKER_METADATA_DIR: '\(.*\)'/\1/p")
  assert [ -n "$dir" ]
  assert [ -d "$dir" ]
  assert [ -f "$dir/labels" ]
  assert [ -f "$dir/tags" ]

  # Check tags
  assert grep -E "^foo/bar:$BUILDKITE_COMMIT$" "$dir/tags"

  # Check labels
  assert grep -E "^org.opencontainers.image.source=$BUILDKITE_REPO$" "$dir/labels"
  assert grep -E "^org.opencontainers.image.revision=$BUILDKITE_COMMIT$" "$dir/labels"
  assert grep -E "^org.opencontainers.image.created=.*$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.title=.*$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.licenses=.*$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.vendor=.*$" "$dir/labels"
  assert grep -E "^org.opencontainers.image.authors=$BUILDKITE_BUILD_CREATOR_TEAMS$" "$dir/labels"

  # Cleanup
  rm -r "$dir"
}

@test "Creates extra tags and labels for one image" {
  export BUILDKITE_PLUGIN_DOCKER_METADATA_IMAGES_0="foo/bar"
  export BUILDKITE_PLUGIN_DOCKER_METADATA_EXTRA_TAGS_0="latest"

  # We can't use bats' `run` function because it executes in a subshell
  # and we'll loose the environment variables.
  run "$PWD/hooks/environment"

  assert_success
  assert_output --regexp "DOCKER_METADATA_DIR: '.*'"
  local dir=$(echo "$output" | sed -n "s/.*DOCKER_METADATA_DIR: '\(.*\)'/\1/p")
  assert [ -n "$dir" ]
  assert [ -d "$dir" ]
  assert [ -f "$dir/labels" ]
  assert [ -f "$dir/tags" ]

  # Check tags
  assert grep -E "^foo/bar:$BUILDKITE_COMMIT$" "$dir/tags"
  assert grep -E "^foo/bar:$BUILDKITE_PLUGIN_DOCKER_METADATA_EXTRA_TAGS_0$" "$dir/tags"

  # Check labels
  assert grep -E "^org.opencontainers.image.source=$BUILDKITE_REPO$" "$dir/labels"
  assert grep -E "^org.opencontainers.image.revision=$BUILDKITE_COMMIT$" "$dir/labels"
  assert grep -E "^org.opencontainers.image.created=.*$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.title=.*$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.licenses=.*$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.vendor=.*$" "$dir/labels"

  # Cleanup
  rm -r "$dir"
}

@test "Creates extra tags and labels for multiple images" {
  export BUILDKITE_PLUGIN_DOCKER_METADATA_IMAGES_0="foo/bar"
  export BUILDKITE_PLUGIN_DOCKER_METADATA_IMAGES_1="beer/tacos"
  export BUILDKITE_PLUGIN_DOCKER_METADATA_IMAGES_2="whiskey/steak"
  export BUILDKITE_PLUGIN_DOCKER_METADATA_IMAGES_3="mezcal/life"
  export BUILDKITE_PLUGIN_DOCKER_METADATA_EXTRA_TAGS_0="everybody"
  export BUILDKITE_PLUGIN_DOCKER_METADATA_EXTRA_TAGS_1="rock"
  export BUILDKITE_PLUGIN_DOCKER_METADATA_EXTRA_TAGS_2="your"
  export BUILDKITE_PLUGIN_DOCKER_METADATA_EXTRA_TAGS_3="body"

  # We can't use bats' `run` function because it executes in a subshell
  # and we'll loose the environment variables.
  run "$PWD/hooks/environment"

  assert_success
  assert_output --regexp "DOCKER_METADATA_DIR: '.*'"
  local dir=$(echo "$output" | sed -n "s/.*DOCKER_METADATA_DIR: '\(.*\)'/\1/p")
  assert [ -n "$dir" ]
  assert [ -d "$dir" ]
  assert [ -f "$dir/labels" ]
  assert [ -f "$dir/tags" ]

  # Check tags
  assert grep -E "^foo/bar:$BUILDKITE_COMMIT$" "$dir/tags"
  assert grep -E "^foo/bar:$BUILDKITE_PLUGIN_DOCKER_METADATA_EXTRA_TAGS_0$" "$dir/tags"
  assert grep -E "^foo/bar:$BUILDKITE_PLUGIN_DOCKER_METADATA_EXTRA_TAGS_1$" "$dir/tags"
  assert grep -E "^foo/bar:$BUILDKITE_PLUGIN_DOCKER_METADATA_EXTRA_TAGS_2$" "$dir/tags"
  assert grep -E "^foo/bar:$BUILDKITE_PLUGIN_DOCKER_METADATA_EXTRA_TAGS_3$" "$dir/tags"
  assert grep -E "^beer/tacos:$BUILDKITE_COMMIT$" "$dir/tags"
  assert grep -E "^beer/tacos:$BUILDKITE_PLUGIN_DOCKER_METADATA_EXTRA_TAGS_0$" "$dir/tags"
  assert grep -E "^beer/tacos:$BUILDKITE_PLUGIN_DOCKER_METADATA_EXTRA_TAGS_1$" "$dir/tags"
  assert grep -E "^beer/tacos:$BUILDKITE_PLUGIN_DOCKER_METADATA_EXTRA_TAGS_2$" "$dir/tags"
  assert grep -E "^beer/tacos:$BUILDKITE_PLUGIN_DOCKER_METADATA_EXTRA_TAGS_3$" "$dir/tags"
  assert grep -E "^whiskey/steak:$BUILDKITE_COMMIT$" "$dir/tags"
  assert grep -E "^whiskey/steak:$BUILDKITE_PLUGIN_DOCKER_METADATA_EXTRA_TAGS_0$" "$dir/tags"
  assert grep -E "^whiskey/steak:$BUILDKITE_PLUGIN_DOCKER_METADATA_EXTRA_TAGS_1$" "$dir/tags"
  assert grep -E "^whiskey/steak:$BUILDKITE_PLUGIN_DOCKER_METADATA_EXTRA_TAGS_2$" "$dir/tags"
  assert grep -E "^whiskey/steak:$BUILDKITE_PLUGIN_DOCKER_METADATA_EXTRA_TAGS_3$" "$dir/tags"
  assert grep -E "^mezcal/life:$BUILDKITE_COMMIT$" "$dir/tags"
  assert grep -E "^mezcal/life:$BUILDKITE_PLUGIN_DOCKER_METADATA_EXTRA_TAGS_0$" "$dir/tags"
  assert grep -E "^mezcal/life:$BUILDKITE_PLUGIN_DOCKER_METADATA_EXTRA_TAGS_1$" "$dir/tags"
  assert grep -E "^mezcal/life:$BUILDKITE_PLUGIN_DOCKER_METADATA_EXTRA_TAGS_2$" "$dir/tags"
  assert grep -E "^mezcal/life:$BUILDKITE_PLUGIN_DOCKER_METADATA_EXTRA_TAGS_3$" "$dir/tags"

  # Check labels
  assert grep -E "^org.opencontainers.image.source=$BUILDKITE_REPO$" "$dir/labels"
  assert grep -E "^org.opencontainers.image.revision=$BUILDKITE_COMMIT$" "$dir/labels"
  assert grep -E "^org.opencontainers.image.created=.*$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.title=.*$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.licenses=.*$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.vendor=.*$" "$dir/labels"

  # Cleanup
  rm -r "$dir"
}

@test "fails if an image is missing" {

  # We can't use bats' `run` function because it executes in a subshell
  # and we'll loose the environment variables.
  run "$PWD/hooks/environment"

  assert_failure
  assert_output --partial "specifying an output image is required."
}

@test "Creates a tag and a label if the git tag is defined" {
  export BUILDKITE_PLUGIN_DOCKER_METADATA_IMAGES_0="foo/bar"
  export BUILDKITE_TAG="v0.1.0"

  # We can't use bats' `run` function because it executes in a subshell
  # and we'll loose the environment variables.
  run "$PWD/hooks/environment"

  assert_success
  assert_output --regexp "DOCKER_METADATA_DIR: '.*'"
  local dir=$(echo "$output" | sed -n "s/.*DOCKER_METADATA_DIR: '\(.*\)'/\1/p")
  assert [ -n "$dir" ]
  assert [ -d "$dir" ]
  assert [ -f "$dir/labels" ]
  assert [ -f "$dir/tags" ]

  # Check tags
  assert grep -E "^foo/bar:$BUILDKITE_COMMIT$" "$dir/tags"
  assert grep -E "^foo/bar:$BUILDKITE_TAG$" "$dir/tags"

  # Check labels
  assert grep -E "^org.opencontainers.image.source=$BUILDKITE_REPO$" "$dir/labels"
  assert grep -E "^org.opencontainers.image.revision=$BUILDKITE_COMMIT$" "$dir/labels"
  assert grep -E "^org.opencontainers.image.version=$BUILDKITE_TAG$" "$dir/labels"
  assert grep -E "^org.opencontainers.image.created=.*$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.title=.*$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.licenses=.*$" "$dir/labels"
  refute grep -E "^org.opencontainers.image.vendor=.*$" "$dir/labels"

  # Cleanup
  rm -r "$dir"
}
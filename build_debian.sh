herdr_app_VERSION=$1
BUILD_VERSION=$2
ARCH=${3:-amd64}  # Default to amd64 if no architecture specified

if [ -z "$herdr_app_VERSION" ] || [ -z "$BUILD_VERSION" ]; then
    echo "Usage: $0 <herdr_app_version> <build_version> [architecture]"
    echo "Example: $0 0.1.9 1 arm64"
    echo "Example: $0 0.1.9 1 all    # Build for all architectures"
    echo "Supported architectures: amd64, arm64, all"
    exit 1
fi

# Function to map Debian architecture to the upstream tarball name
get_herdr_app_release() {
    local arch=$1
    case "$arch" in
        "amd64")
            echo "herdr-app-linux-x86_64"
            ;;
        "arm64")
            echo "herdr-app-linux-aarch64"
            ;;
        *)
            echo ""
            ;;
    esac
}

# The oldest herdr-core this release works with (it refuses older cores), from
# upstream's source at the release tag; it becomes a versioned Depends
CORE_MIN=$(wget -qO- "https://raw.githubusercontent.com/herdrdev/herdr-app/v${herdr_app_VERSION}/distribution/core-version" | tr -d '[:space:]')
if ! [[ "$CORE_MIN" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "❌ Could not read distribution/core-version for v${herdr_app_VERSION} (got '$CORE_MIN')"
    exit 1
fi
echo "herdr-app $herdr_app_VERSION needs herdr-core >= $CORE_MIN"

# Function to build for a specific architecture
build_architecture() {
    local build_arch=$1
    local herdr_app_release

    herdr_app_release=$(get_herdr_app_release "$build_arch")
    if [ -z "$herdr_app_release" ]; then
        echo "❌ Unsupported architecture: $build_arch"
        echo "Supported architectures: amd64, arm64"
        return 1
    fi

    echo "Building for architecture: $build_arch using $herdr_app_release"

    # Clean up any previous builds for this architecture
    rm -rf "$herdr_app_release" || true
    rm -f "${herdr_app_release}.tar.gz" || true

    # Upstream publishes its builds on releases.herdr.dev, not on GitHub Releases
    if ! wget "https://releases.herdr.dev/app/${herdr_app_VERSION}/${herdr_app_release}.tar.gz"; then
        echo "❌ Failed to download herdr-app for $build_arch"
        return 1
    fi

    # The tarball holds a single herdr-app/ folder: the binary, its icon,
    # LICENSE and THIRD-PARTY-NOTICES
    mkdir -p "$herdr_app_release"
    if ! tar -xzf "${herdr_app_release}.tar.gz" -C "$herdr_app_release" --strip-components=1; then
        echo "❌ Failed to extract herdr-app for $build_arch"
        return 1
    fi

    rm -f "${herdr_app_release}.tar.gz"

    if [ ! -f "$herdr_app_release/herdr-app" ] || [ ! -f "$herdr_app_release/herdr-app.svg" ]; then
        echo "❌ Unexpected tarball layout: $herdr_app_release/herdr-app or herdr-app.svg not found"
        return 1
    fi

    # One package for every suite: upstream ships one binary per architecture,
    # so only the old ~<suite> version suffix ever differed. The fixed ~griffo
    # keeps it below the distro's own build of the same version.
    FULL_VERSION="$herdr_app_VERSION-${BUILD_VERSION}~griffo_${build_arch}"
    echo "  Building $FULL_VERSION"

    if ! docker build . -t "herdr-app-$build_arch" \
        --build-arg herdr_app_VERSION="$herdr_app_VERSION" \
        --build-arg BUILD_VERSION="$BUILD_VERSION" \
        --build-arg FULL_VERSION="$FULL_VERSION" \
        --build-arg ARCH="$build_arch" \
        --build-arg HERDR_APP_RELEASE="$herdr_app_release" \
        --build-arg CORE_MIN="$CORE_MIN"; then
        echo "❌ Failed to build Docker image for $build_arch"
        return 1
    fi

    id="$(docker create "herdr-app-$build_arch")"
    if ! docker cp "$id:/herdr-app_$FULL_VERSION.deb" - > "./herdr-app_$FULL_VERSION.deb"; then
        echo "❌ Failed to extract .deb package for $build_arch"
        return 1
    fi

    if ! tar -xf "./herdr-app_$FULL_VERSION.deb"; then
        echo "❌ Failed to extract .deb contents for $build_arch"
        return 1
    fi

    # Clean up extracted directory
    rm -rf "$herdr_app_release" || true

    echo "✅ Successfully built for $build_arch"
    return 0
}

# Main build logic
if [ "$ARCH" = "all" ]; then
    echo "🚀 Building herdr-app $herdr_app_VERSION-$BUILD_VERSION for all supported architectures..."
    echo ""

    # All supported architectures (upstream publishes amd64 and arm64 only)
    ARCHITECTURES=("amd64" "arm64")

    for build_arch in "${ARCHITECTURES[@]}"; do
        echo "==========================================="
        echo "Building for architecture: $build_arch"
        echo "==========================================="

        if ! build_architecture "$build_arch"; then
            echo "❌ Failed to build for $build_arch"
            exit 1
        fi

        echo ""
    done

    echo "🎉 All architectures built successfully!"
    echo "Generated packages:"
    ls -la herdr-app_*.deb
else
    # Build for single architecture
    if ! build_architecture "$ARCH"; then
        exit 1
    fi
fi

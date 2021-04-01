curl -LJ "https://api.adoptopenjdk.net/v3/binary/latest/11/ga/linux/x64/jdk/hotspot/normal/adoptopenjdk" --output /tmp/openjdk-11.tar.gz
mkdir -p /usr/lib/jvm
tar xfvz /tmp/openjdk-11.tar.gz --directory /usr/lib/jvm
rm -f /tmp/openjdk-11.tar.gz
sh -c 'for bin in /usr/lib/jvm/jdk-11*/bin/*; do update-alternatives --install /usr/bin/$(basename $bin) $(basename $bin) $bin 100; done'
sh -c 'for bin in /usr/lib/jvm/jdk-11*/bin/*; do update-alternatives --set $(basename $bin) $bin; done'
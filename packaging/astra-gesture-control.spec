Name:           astra-gesture-control
Version:        1.0.0
Release:        1%{?dist}
Summary:        Remote control your desktop with gestures

License:        MIT
URL:            https://github.com/adityadhara040505/Astra_Gesture_Control
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  gcc
BuildRequires:  cargo
BuildRequires:  rust
Requires:       glibc
Requires:       libgcc
Requires:       libstdc++

%description
Astra Gesture Control allows you to control your desktop computer
using gestures from your mobile device. Features include mouse control,
keyboard input, and customizable sensitivity settings.

This package includes both the server component and a graphical
user interface for easy configuration and monitoring.

%prep
%setup -q

%build
cargo build --release

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/usr/bin
mkdir -p $RPM_BUILD_ROOT/usr/share/applications
mkdir -p $RPM_BUILD_ROOT/usr/share/icons/hicolor/512x512/apps
mkdir -p $RPM_BUILD_ROOT/usr/share/doc/%{name}

install -m 755 target/release/astra-remote $RPM_BUILD_ROOT/usr/bin/
install -m 755 target/release/astra-gui $RPM_BUILD_ROOT/usr/bin/
install -m 644 astra-gesture-control.desktop $RPM_BUILD_ROOT/usr/share/applications/
install -m 644 assets/icon.png $RPM_BUILD_ROOT/usr/share/icons/hicolor/512x512/apps/astra-gesture-control.png
install -m 644 README.md $RPM_BUILD_ROOT/usr/share/doc/%{name}/

%files
/usr/bin/astra-remote
/usr/bin/astra-gui
/usr/share/applications/astra-gesture-control.desktop
/usr/share/icons/hicolor/512x512/apps/astra-gesture-control.png
%doc /usr/share/doc/%{name}/README.md

%post
update-desktop-database &> /dev/null || :
gtk-update-icon-cache -f -t /usr/share/icons/hicolor &> /dev/null || :

%postun
update-desktop-database &> /dev/null || :
gtk-update-icon-cache -f -t /usr/share/icons/hicolor &> /dev/null || :

%changelog
* Thu Jan 23 2026 Astra Team <astra@example.com> - 1.0.0-1
- Initial release

Summary: Windowmanager Puppet Module
Name: pupmod-windowmanager
Version: 4.1.0
Release: 4
License: Apache License, Version 2.0
Group: Applications/System
Source: %{name}-%{version}-%{release}.tar.gz
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Requires: puppet >= 3.3.0
Requires: pupmod-mozilla >= 2.0.0-4
Requires: puppetlabs-stdlib >= 4.1.0-0
Buildarch: noarch
Requires: simp-bootstrap >= 4.2.0
Obsoletes: pupmod-windowmanager-test
Requires: pupmod-onyxpoint-compliance_markup

Prefix:"/etc/puppet/environments/simp/modules"

%description
This Puppet module provides useful settings to setup various Window Managers.
Currently Supported:
  - GNOME

%prep
%setup -q

%build

%install
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/windowmanager

dirs='files lib manifests templates'
for dir in $dirs; do
  test -d $dir && cp -r $dir %{buildroot}/%{prefix}/windowmanager
done

mkdir -p %{buildroot}/usr/share/simp/tests/modules/windowmanager

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/windowmanager

%files
%defattr(0640,root,puppet,0750)
/etc/puppet/environments/simp/modules/windowmanager

%post
#!/bin/sh

if [ -d /etc/puppet/environments/simp/modules/windowmanager/plugins ]; then
  /bin/mv /etc/puppet/environments/simp/modules/windowmanager/plugins /etc/puppet/environments/simp/modules/windowmanager/plugins.bak
fi

%postun
# Post uninstall stuff

%changelog
* Tue Jun 7 2016 Ralph Wright <rwright@onyxpoint.com> - 4.1.0-4
- Added dconf support
- Added security settings using dconf

* Tue Mar 01 2016 Ralph Wright <ralph.wright@onyxpoint.com> - 4.1.0-3
- Added compliance function support

* Fri Jan 16 2015 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-2
- Changed puppet-server requirement to puppet

* Tue Sep 30 2014 Nick Markowski <nmarkowski@keywcorp.com> - 4.1.0-1
- Updated for RHEL7

* Thu Mar 20 2014 Nick Markowski <nmarkowski@keywcorp.com> - 4.1.0-0
- Updated for puppet3/hiera and added rspec tests

* Wed Oct 02 2013 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.0.0-6
- Use 'versioncmp' for all version comparisons.

* Fri May 03 2013 Nick Markowski <nmarkowski@keywcorp.com>
4.0.0-5
- Added pupmod-mozilla as a dependency

* Tue Dec 11 2012 Maintenance
4.0.0-4
- Created a Cucumber test to ensure that windowmanager install correctly from
  the windowmanager module with all dependencies.

* Fri May 25 2012 Maintenance
4.0.0-3
- Added a windowmanager::gnome::sec class that is included by default and
  provides some common security settings via gconf.
- Moved mit-tests to /usr/share/simp...
- Updated pp files to better meet Puppet's recommended style guide.

* Fri Mar 02 2012 Maintenance
4.0.0-2
- Improved test stubs.

* Mon Dec 26 2011 Maintenance
4.0.0-1
- Updated the spec file to not require a separate file list.

* Wed Nov 02 2011 Maintenance
4.0.0-0
- Updated to handle RHEL6

* Tue Jan 11 2011 Maintenance
2.0.0-0
- Refactored for SIMP-2.0.0-alpha release

* Tue Oct 26 2010 Maintenance - 1-1
- Converting all spec files to check for directories prior to copy.

* Mon May 24 2010 Maintenance
1.0-0
- Code refactoring.

* Thu Oct 1 2009 Maintenance
0.1-0
- Initial Release

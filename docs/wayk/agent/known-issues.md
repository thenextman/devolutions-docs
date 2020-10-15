---
uid: wayk-agent-known-issues
---

# Wayk Agent Known Issues

## RDP Black Screen

If you first connect with RDP and then connect with Wayk to the same Windows user session, minimizing the RDP client window can result in a black screen in Wayk. This is because the RDP client sends a message that causes all remote graphics rendering to stop.

## Virtual Machine Black Screen

With VirtualBox, 3D acceleration breaks screen sharing because the 3D rendering occurs on the virtual machine host, making it impossible to capture from the guest. Therefore, 3D acceleration must be disabled.

With Parallels, 3D acceleration breaks screen sharing. The reason and the solution are the same as for VirtualBox.

## Linux Black Screen

Ubuntu 18.04 and later defaults to Wayland instead of xorg-server (X11), but display capturing is currently not possible with Wayland, resulting in a black screen. To work around the problem, the default should be changed to xorg-server. You can follow instructions from this [blog post](https://linuxconfig.org/how-to-disable-wayland-and-enable-xorg-display-server-on-ubuntu-18-04-bionic-beaver-linux).

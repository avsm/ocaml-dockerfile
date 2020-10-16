(*
 * Copyright (c) 2016-2017 Anil Madhavapeddy <anil@recoil.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *)

(** Distro selection for various OPAM combinations *)
open Astring

type t = [
  | `Alpine of [ `V3_3 | `V3_4 | `V3_5 | `V3_6 | `V3_7 | `V3_8 | `V3_9 | `V3_10 | `V3_11 | `V3_12 | `Latest ]
  | `CentOS of [ `V6 | `V7 | `V8 | `Latest ]
  | `Debian of [ `V10 | `V9 | `V8 | `V7 | `Stable | `Testing | `Unstable ]
  | `Fedora of [ `V21 | `V22 | `V23 | `V24 | `V25 | `V26 | `V27 | `V28 | `V29 | `V30 | `V31 | `V32 | `Latest ]
  | `OracleLinux of [ `V7 | `V8 | `Latest ]
  | `OpenSUSE of [ `V42_1 | `V42_2 | `V42_3 | `V15_0 | `V15_1 | `V15_2 | `Latest ]
  | `Ubuntu of [ `V12_04 | `V14_04 | `V15_04 | `V15_10 | `V16_04 | `V16_10 | `V17_04 | `V17_10 | `V18_04 | `V18_10 | `V19_04 | `V19_10 | `V20_04 | `LTS | `Latest ]
] [@@deriving sexp]

type status = [
  | `Deprecated
  | `Active of [ `Tier1 | `Tier2 ]
  | `Alias of t
] [@@deriving sexp]

let distros = [
  `Alpine `V3_3; `Alpine `V3_4; `Alpine `V3_5; `Alpine `V3_6;
  `Alpine `V3_7; `Alpine `V3_8; `Alpine `V3_9; `Alpine `V3_10;
  `Alpine `V3_11; `Alpine `V3_12;
  `Alpine `Latest;

  `CentOS `V6; `CentOS `V7; `CentOS `V8; `CentOS `Latest;

  `Debian `V7; `Debian `V8; `Debian `V9; `Debian `V10;
  `Debian `Stable; `Debian `Testing; `Debian `Unstable;

  `Fedora `V23; `Fedora `V24; `Fedora `V25; `Fedora `V26; `Fedora `V27;
  `Fedora `V28; `Fedora `V29; `Fedora `V30; `Fedora `V31; `Fedora `V32;
  `Fedora `Latest;

  `OracleLinux `V7; `OracleLinux `V8; `OracleLinux `Latest;

  `OpenSUSE `V42_1; `OpenSUSE `V42_2; `OpenSUSE `V42_3; `OpenSUSE `V15_0;
  `OpenSUSE `V15_1; `OpenSUSE `V15_2;
  `OpenSUSE `Latest;

  `Ubuntu `V12_04; `Ubuntu `V14_04; `Ubuntu `V15_04; `Ubuntu `V15_10;
  `Ubuntu `V16_04; `Ubuntu `V16_10; `Ubuntu `V17_04; `Ubuntu `V17_10;
  `Ubuntu `V18_04; `Ubuntu `V18_10; `Ubuntu `V19_04; `Ubuntu `V19_10; `Ubuntu `V20_04;
  `Ubuntu `Latest; `Ubuntu `LTS;
]

let distro_status (d:t) : status = match d with
  | `Alpine ( `V3_3 | `V3_4 | `V3_5 | `V3_6 | `V3_7 | `V3_8 | `V3_9 | `V3_10 | `V3_11) -> `Deprecated
  | `Alpine `V3_12 -> `Active `Tier1
  | `Alpine `Latest -> `Alias (`Alpine `V3_12)
  | `CentOS (`V6 | `V7) -> `Deprecated
  | `CentOS `V8 -> `Active `Tier2
  | `CentOS `Latest -> `Alias (`CentOS `V8)
  | `Debian (`V7 | `V8 | `V9) -> `Deprecated
  | `Debian `V10 -> `Active `Tier1
  | `Debian `Stable -> `Alias (`Debian `V10)
  | `Debian `Testing -> `Active `Tier2
  | `Debian `Unstable -> `Active `Tier2
  | `Fedora ( `V21 | `V22 | `V23 | `V24 | `V25 | `V26 | `V27 | `V28 | `V29 | `V30 | `V31) -> `Deprecated
  | `Fedora `V32 -> `Active `Tier2
  | `Fedora `Latest -> `Alias (`Fedora `V32)
  | `OracleLinux `V7 -> `Deprecated
  | `OracleLinux `V8 -> `Active `Tier2
  | `OracleLinux `Latest -> `Alias (`OracleLinux `V8)
  | `OpenSUSE (`V42_1 | `V42_2 | `V42_3 | `V15_0 | `V15_1) -> `Deprecated
  | `OpenSUSE `V15_2 -> `Active `Tier2
  | `OpenSUSE `Latest -> `Alias (`OpenSUSE `V15_2)
  | `Ubuntu (`V16_04 | `V18_04 | `V20_04) -> `Active `Tier2
  | `Ubuntu ( `V12_04 | `V14_04 | `V15_04 | `V15_10 | `V16_10 | `V17_04 | `V17_10 | `V18_10 | `V19_04 | `V19_10 ) -> `Deprecated
  | `Ubuntu `LTS -> `Alias (`Ubuntu `V18_04)
  | `Ubuntu `Latest -> `Alias (`Ubuntu `V20_04)

let latest_distros =
  [ `Alpine `Latest; `CentOS `Latest;
    `Debian `Stable; `Debian `Testing; `Debian Unstable;
    `OracleLinux `Latest; `OpenSUSE `Latest; `Fedora `Latest;
    `Ubuntu `Latest; `Ubuntu `LTS ]

let master_distro = `Debian `Stable

let resolve_alias d =
  match distro_status d with
  | `Alias x -> x
  | _ -> d

module OV = Ocaml_version

let distro_arches ov (d:t) =
  match resolve_alias d, ov with
  | `Debian `V10, ov when OV.(compare Releases.v4_05_0 ov) = -1 -> [ `I386; `X86_64; `Aarch64; `Ppc64le; `Aarch32 ]
  | `Debian `V9, ov when OV.(compare Releases.v4_05_0 ov) = -1 -> [ `I386; `X86_64; `Aarch64; `Aarch32 ]
  | `Alpine (`V3_6 | `V3_7 | `V3_8 | `V3_9 | `V3_10 | `V3_11 | `V3_12), ov when OV.(compare Releases.v4_05_0 ov) = -1 -> [ `X86_64; `Aarch64 ]
  | `Ubuntu (`V18_04|`V20_04), ov when OV.(compare Releases.v4_05_0 ov) = -1  -> [ `X86_64; `Aarch64; `Ppc64le ]
  | _ -> [ `X86_64 ]


let distro_supported_on a ov (d:t) =
  List.mem a (distro_arches ov d)

let active_distros arch =
  List.filter (fun d -> match distro_status d with `Active _ -> true | _ -> false ) distros |>
  List.filter (distro_supported_on arch OV.Releases.latest)

let active_tier1_distros arch =
  List.filter (fun d -> match distro_status d with `Active `Tier1 -> true | _ -> false ) distros |>
  List.filter (distro_supported_on arch OV.Releases.latest)

let active_tier2_distros arch =
  List.filter (fun d -> match distro_status d with `Active `Tier2 -> true | _ -> false ) distros |>
  List.filter (distro_supported_on arch OV.Releases.latest)

(* The distro-supplied version of OCaml *)
let builtin_ocaml_of_distro (d:t) : string option =
  match resolve_alias d with
  |`Debian `V7 -> Some "3.12.1"
  |`Debian `V8 -> Some "4.01.0"
  |`Debian `V9 -> Some "4.02.3"
  |`Debian `V10 -> Some "4.05.0"
  |`Ubuntu `V12_04 -> Some "3.12.1"
  |`Ubuntu `V14_04 -> Some "4.01.0"
  |`Ubuntu `V15_04 -> Some "4.01.0"
  |`Ubuntu `V15_10 -> Some "4.01.0"
  |`Ubuntu `V16_04 -> Some "4.02.3"
  |`Ubuntu `V16_10 -> Some "4.02.3"
  |`Ubuntu `V17_04 -> Some "4.02.3"
  |`Ubuntu `V17_10 -> Some "4.04.0"
  |`Ubuntu `V18_04 -> Some "4.05.0"
  |`Ubuntu `V18_10 -> Some "4.05.0"
  |`Ubuntu `V19_04 -> Some "4.05.0"
  |`Ubuntu `V19_10 -> Some "4.05.0"
  |`Ubuntu `V20_04 -> Some "4.08.1"
  |`Alpine `V3_3 -> Some "4.02.3"
  |`Alpine `V3_4 -> Some "4.02.3"
  |`Alpine `V3_5 -> Some "4.04.0"
  |`Alpine `V3_6 -> Some "4.04.1"
  |`Alpine `V3_7 -> Some "4.04.2"
  |`Alpine `V3_8 -> Some "4.06.1"
  |`Alpine `V3_9 -> Some "4.06.1"
  |`Alpine `V3_10 -> Some "4.07.0"
  |`Alpine `V3_11 -> Some "4.08.1"
  |`Alpine `V3_12 -> Some "4.08.1"
  |`Fedora `V21 -> Some "4.01.0"
  |`Fedora `V22 -> Some "4.02.0"
  |`Fedora `V23 -> Some "4.02.2"
  |`Fedora `V24 -> Some "4.02.3"
  |`Fedora `V25 -> Some "4.02.3"
  |`Fedora `V26 -> Some "4.04.0"
  |`Fedora `V27 -> Some "4.05.0"
  |`Fedora `V28 -> Some "4.06.0"
  |`Fedora `V29 -> Some "4.07.0"
  |`Fedora `V30 -> Some "4.07.0"
  |`Fedora `V31 -> Some "4.08.1"
  |`Fedora `V32 -> Some "4.10.0"
  |`CentOS `V6 -> Some "3.11.2"
  |`CentOS `V7 -> Some "4.01.0"
  |`CentOS `V8 -> Some "4.07.0"
  |`OpenSUSE `V42_1 -> Some "4.02.3"
  |`OpenSUSE `V42_2 -> Some "4.03.0"
  |`OpenSUSE `V42_3 -> Some "4.03.0"
  |`OpenSUSE `V15_0 -> Some "4.05.0"
  |`OpenSUSE `V15_1 -> Some "4.05.0"
  |`OpenSUSE `V15_2 -> Some "4.05.0"
  |`OracleLinux `V7 -> None
  |`OracleLinux `V8 -> None
  |`Alpine `Latest |`CentOS `Latest |`OracleLinux `Latest
  |`OpenSUSE `Latest |`Ubuntu `LTS | `Ubuntu `Latest
  |`Debian (`Testing | `Unstable | `Stable) |`Fedora `Latest -> assert false

(* The Docker tag for this distro *)
let tag_of_distro (d:t) = match d with
  |`Ubuntu `V12_04 -> "ubuntu-12.04"
  |`Ubuntu `V14_04 -> "ubuntu-14.04"
  |`Ubuntu `V15_04 -> "ubuntu-15.04"
  |`Ubuntu `V15_10 -> "ubuntu-15.10"
  |`Ubuntu `V16_04 -> "ubuntu-16.04"
  |`Ubuntu `V16_10 -> "ubuntu-16.10"
  |`Ubuntu `V17_04 -> "ubuntu-17.04"
  |`Ubuntu `V17_10 -> "ubuntu-17.10"
  |`Ubuntu `V18_04 -> "ubuntu-18.04"
  |`Ubuntu `V18_10 -> "ubuntu-18.10"
  |`Ubuntu `V19_04 -> "ubuntu-19.04"
  |`Ubuntu `V19_10 -> "ubuntu-19.10"
  |`Ubuntu `V20_04 -> "ubuntu-20.04"
  |`Ubuntu `Latest -> "ubuntu"
  |`Ubuntu `LTS -> "ubuntu-lts"
  |`Debian `Stable -> "debian-stable"
  |`Debian `Unstable -> "debian-unstable"
  |`Debian `Testing -> "debian-testing"
  |`Debian `V10 -> "debian-10"
  |`Debian `V9 -> "debian-9"
  |`Debian `V8 -> "debian-8"
  |`Debian `V7 -> "debian-7"
  |`CentOS `V6 -> "centos-6"
  |`CentOS `V7 -> "centos-7"
  |`CentOS `V8 -> "centos-8"
  |`CentOS `Latest -> "centos"
  |`Fedora `Latest -> "fedora"
  |`Fedora `V21 -> "fedora-21"
  |`Fedora `V22 -> "fedora-22"
  |`Fedora `V23 -> "fedora-23"
  |`Fedora `V24 -> "fedora-24"
  |`Fedora `V25 -> "fedora-25"
  |`Fedora `V26 -> "fedora-26"
  |`Fedora `V27 -> "fedora-27"
  |`Fedora `V28 -> "fedora-28"
  |`Fedora `V29 -> "fedora-29"
  |`Fedora `V30 -> "fedora-30"
  |`Fedora `V31 -> "fedora-31"
  |`Fedora `V32 -> "fedora-32"
  |`OracleLinux `V7 -> "oraclelinux-7"
  |`OracleLinux `V8 -> "oraclelinux-8"
  |`OracleLinux `Latest -> "oraclelinux"
  |`Alpine `V3_3 -> "alpine-3.3"
  |`Alpine `V3_4 -> "alpine-3.4"
  |`Alpine `V3_5 -> "alpine-3.5"
  |`Alpine `V3_6 -> "alpine-3.6"
  |`Alpine `V3_7 -> "alpine-3.7"
  |`Alpine `V3_8 -> "alpine-3.8"
  |`Alpine `V3_9 -> "alpine-3.9"
  |`Alpine `V3_10 -> "alpine-3.10"
  |`Alpine `V3_11 -> "alpine-3.11"
  |`Alpine `V3_12 -> "alpine-3.12"
  |`Alpine `Latest -> "alpine"
  |`OpenSUSE `V42_1 -> "opensuse-42.1"
  |`OpenSUSE `V42_2 -> "opensuse-42.2"
  |`OpenSUSE `V42_3 -> "opensuse-42.3"
  |`OpenSUSE `V15_0 -> "opensuse-15.0"
  |`OpenSUSE `V15_1 -> "opensuse-15.1"
  |`OpenSUSE `V15_2 -> "opensuse-15.2"
  |`OpenSUSE `Latest -> "opensuse"

let distro_of_tag x : t option = match x with
  |"ubuntu-12.04" -> Some (`Ubuntu `V12_04)
  |"ubuntu-14.04" -> Some (`Ubuntu `V14_04)
  |"ubuntu-15.04" -> Some (`Ubuntu `V15_04)
  |"ubuntu-15.10" -> Some (`Ubuntu `V15_10)
  |"ubuntu-16.04" -> Some (`Ubuntu `V16_04)
  |"ubuntu-16.10" -> Some (`Ubuntu `V16_10)
  |"ubuntu-17.04" -> Some (`Ubuntu `V17_04)
  |"ubuntu-17.10" -> Some (`Ubuntu `V17_10)
  |"ubuntu-18.04" -> Some (`Ubuntu `V18_04)
  |"ubuntu-18.10" -> Some (`Ubuntu `V18_10)
  |"ubuntu-19.04" -> Some (`Ubuntu `V19_04)
  |"ubuntu-19.10" -> Some (`Ubuntu `V19_10)
  |"ubuntu-20.04" -> Some (`Ubuntu `V20_04)
  |"ubuntu" -> Some (`Ubuntu `Latest)
  |"ubuntu-lts" -> Some (`Ubuntu `LTS)
  |"debian-stable" -> Some (`Debian `Stable)
  |"debian-unstable" -> Some (`Debian `Unstable)
  |"debian-testing" -> Some (`Debian `Testing)
  |"debian-10" -> Some (`Debian `V10)
  |"debian-9" -> Some (`Debian `V9)
  |"debian-8" -> Some (`Debian `V8)
  |"debian-7" -> Some (`Debian `V7)
  |"centos-6" -> Some (`CentOS `V6)
  |"centos-7" -> Some (`CentOS `V7)
  |"centos-8" -> Some (`CentOS `V8)
  |"fedora-21" -> Some (`Fedora `V21)
  |"fedora-22" -> Some (`Fedora `V22)
  |"fedora-23" -> Some (`Fedora `V23)
  |"fedora-24" -> Some (`Fedora `V24)
  |"fedora-25" -> Some (`Fedora `V25)
  |"fedora-26" -> Some (`Fedora `V26)
  |"fedora-27" -> Some (`Fedora `V27)
  |"fedora-28" -> Some (`Fedora `V28)
  |"fedora-29" -> Some (`Fedora `V29)
  |"fedora-30" -> Some (`Fedora `V30)
  |"fedora-31" -> Some (`Fedora `V31)
  |"fedora-32" -> Some (`Fedora `V32)
  |"fedora" -> Some (`Fedora `Latest)
  |"oraclelinux-7" -> Some (`OracleLinux `V7)
  |"oraclelinux-8" -> Some (`OracleLinux `V8)
  |"oraclelinux" -> Some (`OracleLinux `Latest)
  |"alpine-3.3" -> Some (`Alpine `V3_3)
  |"alpine-3.4" -> Some (`Alpine `V3_4)
  |"alpine-3.5" -> Some (`Alpine `V3_5)
  |"alpine-3.6" -> Some (`Alpine `V3_6)
  |"alpine-3.7" -> Some (`Alpine `V3_7)
  |"alpine-3.8" -> Some (`Alpine `V3_8)
  |"alpine-3.9" -> Some (`Alpine `V3_9)
  |"alpine-3.10" -> Some (`Alpine `V3_10)
  |"alpine-3.11" -> Some (`Alpine `V3_11)
  |"alpine-3.12" -> Some (`Alpine `V3_12)
  |"alpine" -> Some (`Alpine `Latest)
  |"opensuse-42.1" -> Some (`OpenSUSE `V42_1)
  |"opensuse-42.2" -> Some (`OpenSUSE `V42_2)
  |"opensuse-42.3" -> Some (`OpenSUSE `V42_3)
  |"opensuse-15.0" -> Some (`OpenSUSE `V15_0)
  |"opensuse-15.1" -> Some (`OpenSUSE `V15_1)
  |"opensuse-15.2" -> Some (`OpenSUSE `V15_2)
  |"opensuse" -> Some (`OpenSUSE `Latest)
  |_ -> None

let rec human_readable_string_of_distro (d:t) =
  let alias () = human_readable_string_of_distro (resolve_alias d) in
  match d with
  |`Ubuntu `V12_04 -> "Ubuntu 12.04"
  |`Ubuntu `V14_04 -> "Ubuntu 14.04"
  |`Ubuntu `V15_04 -> "Ubuntu 15.04"
  |`Ubuntu `V15_10 -> "Ubuntu 15.10"
  |`Ubuntu `V16_04 -> "Ubuntu 16.04"
  |`Ubuntu `V16_10 -> "Ubuntu 16.10"
  |`Ubuntu `V17_04 -> "Ubuntu 17.04"
  |`Ubuntu `V17_10 -> "Ubuntu 17.10"
  |`Ubuntu `V18_04 -> "Ubuntu 18.04"
  |`Ubuntu `V18_10 -> "Ubuntu 18.10"
  |`Ubuntu `V19_04 -> "Ubuntu 19.04"
  |`Ubuntu `V19_10 -> "Ubuntu 19.10"
  |`Ubuntu `V20_04 -> "Ubuntu 20.04"
  |`Debian `Stable -> "Debian Stable"
  |`Debian `Unstable -> "Debian Unstable"
  |`Debian `Testing -> "Debian Testing"
  |`Debian `V10 -> "Debian 10 (Buster)"
  |`Debian `V9 -> "Debian 9 (Stretch)"
  |`Debian `V8 -> "Debian 8 (Jessie)"
  |`Debian `V7 -> "Debian 7 (Wheezy)"
  |`CentOS `V6 -> "CentOS 6"
  |`CentOS `V7 -> "CentOS 7"
  |`CentOS `V8 -> "CentOS 8"
  |`Fedora `V21 -> "Fedora 21"
  |`Fedora `V22 -> "Fedora 22"
  |`Fedora `V23 -> "Fedora 23"
  |`Fedora `V24 -> "Fedora 24"
  |`Fedora `V25 -> "Fedora 25"
  |`Fedora `V26 -> "Fedora 26"
  |`Fedora `V27 -> "Fedora 27"
  |`Fedora `V28 -> "Fedora 28"
  |`Fedora `V29 -> "Fedora 29"
  |`Fedora `V30 -> "Fedora 30"
  |`Fedora `V31 -> "Fedora 31"
  |`Fedora `V32 -> "Fedora 32"
  |`OracleLinux `V7 -> "OracleLinux 7"
  |`OracleLinux `V8 -> "OracleLinux 8"
  |`Alpine `V3_3 -> "Alpine 3.3"
  |`Alpine `V3_4 -> "Alpine 3.4"
  |`Alpine `V3_5 -> "Alpine 3.5"
  |`Alpine `V3_6 -> "Alpine 3.6"
  |`Alpine `V3_7 -> "Alpine 3.7"
  |`Alpine `V3_8 -> "Alpine 3.8"
  |`Alpine `V3_9 -> "Alpine 3.9"
  |`Alpine `V3_10 -> "Alpine 3.10"
  |`Alpine `V3_11 -> "Alpine 3.11"
  |`Alpine `V3_12 -> "Alpine 3.12"
  |`OpenSUSE `V42_1 -> "OpenSUSE 42.1"
  |`OpenSUSE `V42_2 -> "OpenSUSE 42.2"
  |`OpenSUSE `V42_3 -> "OpenSUSE 42.3"
  |`OpenSUSE `V15_0 -> "OpenSUSE 15.0 (Leap)"
  |`OpenSUSE `V15_1 -> "OpenSUSE 15.1 (Leap)"
  |`OpenSUSE `V15_2 -> "OpenSUSE 15.2 (Leap)"
  |`Alpine `Latest | `Ubuntu `Latest | `Ubuntu `LTS | `CentOS `Latest | `Fedora `Latest
  |`OracleLinux `Latest | `OpenSUSE `Latest -> alias ()

let human_readable_short_string_of_distro (t:t) =
  match t with
  |`Ubuntu _ ->  "Ubuntu"
  |`Debian _ -> "Debian"
  |`CentOS _ -> "CentOS"
  |`Fedora _ -> "Fedora"
  |`OracleLinux _ -> "OracleLinux"
  |`Alpine _ -> "Alpine"
  |`OpenSUSE _ -> "OpenSUSE"

(* The alias tag for the latest stable version of this distro *)
let latest_tag_of_distro (t:t) =
  match t with
  |`Ubuntu _ ->  "ubuntu"
  |`Debian _ -> "debian"
  |`CentOS _ -> "centos"
  |`Fedora _ -> "fedora"
  |`OracleLinux _ -> "oraclelinux"
  |`Alpine _ -> "alpine"
  |`OpenSUSE _ -> "opensuse"

type package_manager = [ `Apt | `Yum | `Apk | `Zypper ] [@@deriving sexp]

let package_manager (t:t) =
  match t with
  |`Ubuntu _ -> `Apt
  |`Debian _ -> `Apt
  |`CentOS _ -> `Yum
  |`Fedora _ -> `Yum
  |`OracleLinux _ -> `Yum
  |`Alpine _ -> `Apk
  |`OpenSUSE _ -> `Zypper

let base_distro_tag ?(arch=`X86_64) d =
  match resolve_alias d with
  | `Alpine v -> begin
        let tag =
          match v with
          | `V3_3 -> "3.3"
          | `V3_4 -> "3.4"
          | `V3_5 -> "3.5"
          | `V3_6 -> "3.6"
          | `V3_7 -> "3.7"
          | `V3_8 -> "3.8"
          | `V3_9 -> "3.9"
          | `V3_10 -> "3.10"
          | `V3_11 -> "3.11"
          | `V3_12 -> "3.12"
          | `Latest -> assert false
        in
        match arch with
        | `I386 -> "i386/alpine", tag
        | _ -> "alpine", tag
   end
   | `Debian v -> begin
        let tag =
          match v with
          | `V7 -> "7"
          | `V8 -> "8"
          | `V9 -> "9"
          | `V10 -> "buster"
          | `Testing -> "testing"
          | `Unstable -> "unstable"
          | `Stable -> assert false
        in
        match arch with
        | `I386 -> "i386/debian", tag
        | `Aarch32 -> "arm32v7/debian", tag
        | _ -> "debian", tag
    end
    | `Ubuntu v ->
        let tag =
          match v with
          | `V12_04 -> "precise"
          | `V14_04 -> "trusty"
          | `V15_04 -> "vivid"
          | `V15_10 -> "wily"
          | `V16_04 -> "xenial"
          | `V16_10 -> "yakkety"
          | `V17_04 -> "zesty"
          | `V17_10 -> "artful"
          | `V18_04 -> "bionic"
          | `V18_10 -> "cosmic"
          | `V19_04 -> "disco"
          | `V19_10 -> "eoan"
          | `V20_04 -> "focal"
          | `Latest | `LTS -> assert false
        in
        "ubuntu", tag
    | `CentOS v ->
        let tag = match v with `V6 -> "6" | `V7 -> "7" | `V8 -> "8" | _ -> assert false in
        "centos", tag
    | `Fedora v ->
        let tag =
          match v with
          | `V21 -> "21"
          | `V22 -> "22"
          | `V23 -> "23"
          | `V24 -> "24"
          | `V25 -> "25"
          | `V26 -> "26"
          | `V27 -> "27"
          | `V28 -> "28"
          | `V29 -> "29"
          | `V30 -> "30"
          | `V31 -> "31"
          | `V32 -> "32"
          | `Latest -> assert false
        in
        "fedora", tag
    | `OracleLinux v ->
        let tag =
          match v with
          | `V7 -> "7"
          | `V8 -> "8"
          | _ -> assert false
        in
        "oraclelinux", tag
    | `OpenSUSE v ->
        let tag =
          match v with
          | `V42_1 -> "42.1"
          | `V42_2 -> "42.2"
          | `V42_3 -> "42.3"
          | `V15_0 -> "15.0"
          | `V15_1 -> "15.1"
          | `V15_2 -> "15.2"
          | `Latest -> assert false
        in
        "opensuse/leap", tag

let compare a b =
  String.compare (human_readable_string_of_distro a) (human_readable_string_of_distro b)

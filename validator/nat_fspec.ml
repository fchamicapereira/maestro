open Core
open Str
open Fspec_api
open Ir
open Common_fspec

let flow_id_struct = Ir.Str ( "FlowId", ["src_port", Uint16;
                                         "dst_port", Uint16;
                                         "src_ip", Uint32;
                                         "dst_ip", Uint32;
                                         "internal_device", Uint16;
                                         "protocol", Uint8;] )

(* FIXME: borrowed from ../nf/vignat/nat_data_spec.ml *)
let containers = ["fm", Map ("FlowId", "max_flows", "");
                  "fv", Vector ("FlowId", "max_flows", "flow_consistency");
                  "heap", DChain "max_flows";
                  "max_flows", Int;
                  "start_port", Int;
                  "ext_ip", UInt32;
                  "nat_device", UInt32;
                  "flow_emap", EMap ("FlowId", "fm", "fv", "heap")]

let records = String.Map.of_alist_exn
                ["FlowId", flow_id_struct]

module Iface : Fspec_api.Spec =
struct
  let preamble = gen_preamble "vignat/nat_loop.h" containers
  let fun_types = fun_types containers records
  let boundary_fun = "loop_invariant_produce"
  let finishing_fun = "loop_invariant_consume"
  let eventproc_iteration_begin = "loop_invariant_produce"
  let eventproc_iteration_end = "loop_invariant_consume"
  let user_check_for_complete_iteration =
    (abstract_state_capture containers) ^
    (In_channel.read_all "forwarding_property.tmpl")
end

(* Register the module *)
let () =
  Fspec_api.spec := Some (module Iface) ;


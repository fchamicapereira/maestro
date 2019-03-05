open Str
open Core
open Fspec_api
open Ir
open Common_fspec

let lb_flow_struct = Ir.Str ( "LoadBalancedFlow", ["src_ip", Uint32;
                                                   "dst_ip", Uint32;
                                                   "src_port", Uint16;
                                                   "dst_port", Uint16;
                                                   "protocol", Uint8;])
let lb_backend_struct = Ir.Str ( "LoadBalancedBackend", ["nic", Uint16;
                                                         "mac", ether_addr_struct;
                                                         "ip", Uint32])

let ip_addr_struct = Ir.Str("ip_addr", ["addr", Uint32])

(* FIXME: borrowed from ../nf/vigbalancer/lb_data_spec.ml*)
let containers = ["flow_to_flow_id", Map ("LoadBalancedFlow", "flow_capacity", "lb_flow_id_condition");
                  "flow_heap", Vector ("LoadBalancedFlow", "flow_capacity", "");
                  "flow_chain", DChain "flow_capacity";
                  "flow_id_to_backend_id", Vector ("uint32_t", "flow_capacity", "lb_flow_id2backend_id_cond");
                  "ip_to_backend_id", Map ("ip_addr", "backend_capacity", "lb_backend_id_condition");
                  "backend_ips", Vector ("ip_addr", "backend_capacity", "");
                  "backends", Vector ("LoadBalancedBackend", "backend_capacity", "lb_backend_condition");
                  "active_backends", DChain "backend_capacity";
                  "cht", CHT ("backend_capacity", "cht_height");
                  "backend_capacity", UInt32;
                  "flow_capacity", UInt32;
                  "cht_height", UInt32;
                  "", EMap ("LoadBalancedFlow", "flow_to_flow_id", "flow_heap", "flow_chain");
                  "", EMap ("ip_addr", "ip_to_backend_id", "backend_ips", "active_backends");
                 ]

let records = String.Map.of_alist_exn
    ["LoadBalancedFlow", lb_flow_struct;
     "ip_addr", ip_addr_struct;
     "uint32_t", Uint32;
     "LoadBalancedBackend", lb_backend_struct]

let fun_types =
  String.Map.of_alist_exn
    (common_fun_types @
     [hash_spec lb_flow_struct;
      "loop_invariant_consume", (loop_invariant_consume_spec containers);
      "loop_invariant_produce", (loop_invariant_produce_spec containers);
      "dchain_allocate", (dchain_alloc_spec (gen_dchain_params containers));
      "dchain_allocate_new_index", (dchain_allocate_new_index_spec (gen_dchain_params containers));
      "dchain_rejuvenate_index", (dchain_rejuvenate_index_spec (gen_dchain_params containers));
      "dchain_is_index_allocated", dchain_is_index_allocated_spec;
      "dchain_free_index", (dchain_free_index_spec (gen_dchain_params containers)) ;
      "expire_items_single_map", (expire_items_single_map_spec (gen_dchain_params containers));
      "map_allocate", (map_alloc_spec (gen_map_params containers records));
      "map_get", (map_get_spec (gen_map_params containers records));
      "map_put", (map_put_spec (gen_map_params containers records));
      "map_erase", (map_erase_spec (gen_map_params containers records));
      "map_size", map_size_spec;
      "cht_find_preferred_available_backend", cht_find_preferred_available_backend_spec;
      "vector_allocate", (vector_alloc_spec (gen_vector_params containers records));
      "cht_fill_cht", cht_fill_cht_spec;
      "vector_borrow", (vector_borrow_spec (gen_vector_params containers records));
      "vector_return", (vector_return_spec (gen_vector_params containers records));])

module Iface : Fspec_api.Spec =
struct
  let preamble = gen_preamble "vigbalancer/lb_loop.h" containers
  let fun_types = fun_types
  let boundary_fun = "loop_invariant_produce"
  let finishing_fun = "loop_invariant_consume"
  let eventproc_iteration_begin = "loop_invariant_produce"
  let eventproc_iteration_end = "loop_invariant_consume"
  let user_check_for_complete_iteration = In_channel.read_all "balancer_forwarding_property.tmpl"
end

(* Register the module *)
let () =
  Fspec_api.spec := Some (module Iface) ;


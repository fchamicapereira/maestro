open Str
open Core
open Fspec_api
open Ir
open Common_fspec

let static_key_struct = Ir.Str ( "StaticKey", ["addr", ether_addr_struct;
                                               "device", Uint16] )
let dynamic_value_struct = Ir.Str ( "DynamicValue", ["device", Uint16] )

(* FIXME: borrowed from ../nf/vigbridge/bridge_data_spec.ml*)
let containers = ["dyn_map", Map ("ether_addr", "capacity", "");
                  "dyn_keys", Vector ("ether_addr", "capacity", "");
                  "dyn_vals", Vector ("DynamicValue", "capacity", "dyn_val_condition");
                  "st_map", Map ("StaticKey", "stat_capacity", "stat_map_condition");
                  "st_vec", Vector ("StaticKey", "stat_capacity", "");
                  "dyn_heap", DChain "capacity";
                  "capacity", UInt32;
                  "stat_capacity", UInt32;
                  "dev_count", UInt32;
                  "", EMap ("ether_addr", "dyn_map", "dyn_keys", "dyn_heap")]

let fun_types =
  String.Map.of_alist_exn
    (common_fun_types @
    [(hash_spec ether_addr_struct);
     "loop_invariant_consume", (loop_invariant_consume_spec containers);
     "loop_invariant_produce", (loop_invariant_produce_spec containers);
     "dchain_allocate", (dchain_alloc_spec [("65536",(Some "ether_addri"))]);
     "dchain_allocate_new_index", (dchain_allocate_new_index_spec (gen_dchain_map_related_specs containers));
     "dchain_rejuvenate_index", (dchain_rejuvenate_index_spec (gen_dchain_map_related_specs containers));
     "expire_items_single_map", (expire_items_single_map_spec ["ether_addri"; "StaticKeyi"]);
     "map_allocate", (map_alloc_spec [("ether_addri","ether_addrp","ether_addr_eq","ether_addr_hash","_ether_addr_hash");
                                      ("StaticKeyi","StaticKeyp","StaticKey_eq","StaticKey_hash","_StaticKey_hash")]) ;
     "map_get", (map_get_spec [
         ("ether_addri","ether_addr","ether_addrp",lma_literal_name "ether_addr","last_ether_addr_searched_in_the_map",ether_addr_struct,(fun name ->
              "//@ open [_]ether_addrp(" ^ name ^ ", _);\n"),true);
         ("StaticKeyi","StaticKey","StaticKeyp",lma_literal_name "StaticKey","last_StaticKey_searched_in_the_map",static_key_struct,
          (fun name ->
             "//@ open StaticKeyp(" ^ name ^ ", _);\n" ^
             "//@ open ether_addrp(" ^ name ^ ".addr, _);\n")
          ,false);]);
     "map_put", (map_put_spec [("ether_addri","ether_addr","ether_addrp",lma_literal_name "ether_addr",ether_addr_struct,true);
                               ("StaticKeyi","StaticKey","StaticKeyp",lma_literal_name "StaticKey",static_key_struct,false)]);
     "vector_allocate", (vector_alloc_spec [("ether_addri","ether_addr","ether_addrp","ether_addr_allocate",true);
                                            ("DynamicValuei","DynamicValue","DynamicValuep","DynamicValue_allocate",false);
                                            ("StaticKeyi","StaticKey","StaticKeyp","StaticKey_allocate",true);]);
     "vector_borrow", (vector_borrow_spec [
         ("ether_addri","ether_addr","ether_addrp",(fun name ->
              "//@ open [_]ether_addrp(*" ^ name ^ ", _);\n"),ether_addr_struct,true);
         ("DynamicValuei","DynamicValue","DynamicValuep",noop,dynamic_value_struct,false);
         ("StaticKeyi","StaticKey","StaticKeyp",noop,static_key_struct,true);]) ;
     "vector_return", (vector_return_spec [("ether_addri","ether_addr","ether_addrp",ether_addr_struct,true);
                                           ("DynamicValuei","DynamicValue","DynamicValuep",dynamic_value_struct,false);
                                           ("StaticKeyi","StaticKey","StaticKeyp",static_key_struct,true);]);])

(* TODO: make external_ip symbolic *)
module Iface : Fspec_api.Spec =
struct
  let preamble = gen_preamble "vigbridge/bridge_loop.h" containers
  let fun_types = fun_types
  let boundary_fun = "loop_invariant_produce"
  let finishing_fun = "loop_invariant_consume"
  let eventproc_iteration_begin = "loop_invariant_produce"
  let eventproc_iteration_end = "loop_invariant_consume"
  let user_check_for_complete_iteration = In_channel.read_all "bridge_forwarding_property.tmpl"
end

(* Register the module *)
let () =
  Fspec_api.spec := Some (module Iface) ;


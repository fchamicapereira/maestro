#ifndef LOOP_H_INCLUDED
#define LOOP_H_INCLUDED

#include "lib/containers/double-chain.h"
#include "lib/containers/double-map.h"
#include "lib/flow.h"

//@ #include "lib/predicates.gh"

#include "lib/coherence.h"

//TODO: coerce this with the definition in rte_stubs.h
#define RTE_NUM_DEVICES 2

/*@
fixpoint bool nat_int_fp(int_k ik, int index) {
    return 0 <= int_k_get_idid(ik) &&
           int_k_get_idid(ik) < RTE_NUM_DEVICES;
}

fixpoint bool nat_ext_fp(ext_k ek, int index) {
    return ext_k_get_esp(ek) == 2747 + index &&
           0 <= ext_k_get_edid(ek) &&
           ext_k_get_edid(ek) < RTE_NUM_DEVICES;
}


predicate evproc_loop_invariant(struct DoubleMap* mp, struct DoubleChain *chp,
                                uint32_t time) =
          dmappingp<int_k,ext_k,flw>(?m, int_k_p, ext_k_p, int_hash, ext_hash,
                                     flw_p, flow_p, flow_keys_offsets_fp,
                                     sizeof(struct flow), flw_get_ik, flw_get_ek,
                                     nat_int_fp, nat_ext_fp, mp) &*&
          double_chainp(?ch, chp) &*&
          dmap_dchain_coherent(m, ch) &*&
          last_time(time) &*&
          dmap_cap_fp(m) == MAX_FLOWS;

@*/

void loop_invariant_consume(struct DoubleMap** m, struct DoubleChain** ch,
                            uint32_t time);
//@ requires *m |-> ?mp &*& *ch |-> ?chp &*& evproc_loop_invariant(mp, chp, time);
//@ ensures *m |-> mp &*& *ch |-> chp;

void loop_invariant_produce(struct DoubleMap** m, struct DoubleChain** ch,
                            uint32_t *time);
//@ requires *m |-> ?mp &*& *ch |-> ?chp &*& *time |-> ?t;
/*@ ensures *m |-> mp &*& *ch |-> chp &*& *time |-> t &*&
            evproc_loop_invariant(mp, chp, t); @*/

void loop_iteration_begin(struct DoubleMap** m, struct DoubleChain** ch,
                          uint32_t time);

void loop_iteration_end(struct DoubleMap** m, struct DoubleChain** ch,
                        uint32_t time);

void loop_enumeration_begin(int cnt);
//@ requires true;
//@ ensures true;

void loop_enumeration_end();
//@ requires true;
//@ ensures true;

#endif//LOOP_H_INCLUDED

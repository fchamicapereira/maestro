#ifdef KLEE_VERIFICATION

#include "loop.h"

#include "lib/models/verified/map-control.h"
#include "lib/models/verified/vector-control.h"
#include "lib/models/verified/vigor-time-control.h"

#include <klee/klee.h>

void loop_reset(struct Map **table, struct Vector **entries,
                unsigned int lcore_id, vigor_time_t *time) {
  map_reset(*table);
  vector_reset(*entries);
  *time = restart_time();
}

void loop_invariant_consume(struct Map **table, struct Vector **entries,
                            unsigned int lcore_id, vigor_time_t time) {
  klee_trace_ret();
  klee_trace_param_ptr(table, sizeof(struct Map *), "table");
  klee_trace_param_ptr(entries, sizeof(struct Vector *), "entries");
  klee_trace_param_i32(lcore_id, "lcore_id");
  klee_trace_param_i64(time, "time");
}

void loop_invariant_produce(struct Map **table, struct Vector **entries,
                            unsigned int *lcore_id, vigor_time_t *time) {
  klee_trace_ret();
  klee_trace_param_ptr(table, sizeof(struct Map *), "table");
  klee_trace_param_ptr(entries, sizeof(struct Vector *), "entries");
  klee_trace_param_ptr(lcore_id, sizeof(unsigned int), "lcore_id");
  klee_trace_param_ptr(time, sizeof(vigor_time_t), "time");
}

void loop_iteration_border(struct Map **table, struct Vector **entries,
                           unsigned int lcore_id, vigor_time_t time) {
  loop_invariant_consume(table, entries, lcore_id, time);
  loop_reset(table, entries, lcore_id, &time);
  loop_invariant_produce(table, entries, &lcore_id, &time);
}

#endif // KLEE_VERIFICATION
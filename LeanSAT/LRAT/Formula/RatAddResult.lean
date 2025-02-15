/-
Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Josh Clune
-/
import LeanSAT.LRAT.Formula.RupAddSound

open Literal

namespace LRAT
namespace DefaultFormula

open Sat DefaultClause DefaultFormula Assignment Misc

theorem insertRatUnits_preserves_assignments_size {n : Nat} (f : DefaultFormula n) (units : List (Literal (PosFin n))) :
  (f.insertRatUnits units).1.assignments.size = f.assignments.size := by
  simp only [insertRatUnits, Prod.mk.eta]
  exact insertUnit_fold_preserves_size f.ratUnits f.assignments false

theorem insertRatUnits_postcondition {n : Nat} (f : DefaultFormula n) (hf : f.ratUnits = #[] ∧ f.assignments.size = n)
  (units : List (Literal (PosFin n))) :
  let assignments := (insertRatUnits f units).fst.assignments
  have hsize : assignments.size = n := by
    rw [← hf.2]
    exact insertRatUnits_preserves_assignments_size f units
  let ratUnits := (insertRatUnits f units).1.ratUnits
  insertUnit_invariant f.assignments hf.2 ratUnits assignments hsize := by
  simp only [insertRatUnits]
  have hsize : f.assignments.size = n := by rw [hf.2]
  have h0 : insertUnit_invariant f.assignments hf.2 f.ratUnits f.assignments hsize := by
    intro i
    simp only [getElem_fin, ne_eq, true_and, Bool.not_eq_true, exists_and_right]
    apply Or.inl
    intro j
    simp only [hf.1, Array.size_toArray, List.length_nil] at j
    exact Fin.elim0 j
  exact insertUnit_fold_preserves_invariant f.assignments hf.2 f.ratUnits f.assignments hsize false units h0

theorem insertRatUnits_nodup {n : Nat} (f : DefaultFormula n) (hf : f.ratUnits = #[] ∧ f.assignments.size = n)
  (units : List (Literal (PosFin n))) :
  ∀ i : Fin (f.insertRatUnits units).1.ratUnits.size, ∀ j : Fin (f.insertRatUnits units).1.ratUnits.size,
  i ≠ j → (f.insertRatUnits units).1.ratUnits[i] ≠ (f.insertRatUnits units).1.ratUnits[j] := by
  intro i j i_ne_j
  rcases hi : (insertRatUnits f units).fst.ratUnits[i] with ⟨li, bi⟩
  rcases hj : (insertRatUnits f units).fst.ratUnits[j] with ⟨lj, bj⟩
  intro heq
  simp only [Prod.mk.injEq] at heq
  rcases heq with ⟨li_eq_lj, bi_eq_bj⟩
  have h := insertRatUnits_postcondition f hf units ⟨li.1, li.2.2⟩
  simp only [ne_eq, Bool.not_eq_true, exists_and_right] at h
  rcases h with ⟨h1, h2⟩ | ⟨k, b, ⟨li_gt_zero, h1⟩, h2, h3, h4⟩ | ⟨k1, k2, li_gt_zero, h1, h2, h3, h4, h5⟩
  . specialize h2 j
    rw [hj, li_eq_lj] at h2
    simp only [not_true] at h2
  . by_cases i = k
    . next i_eq_k =>
      have j_ne_k : j ≠ k := by rw [← i_eq_k]; exact i_ne_j.symm
      specialize h4 j j_ne_k
      rw [hj, li_eq_lj] at h4
      simp (config := { decide := true }) only at h4
    . next i_ne_k =>
      specialize h4 i i_ne_k
      rw [hi] at h4
      simp only [not_true] at h4
  . by_cases bi
    . next bi_eq_true =>
      by_cases i = k1
      . next i_eq_k1 =>
        have j_ne_k1 : j ≠ k1 := by rw [← i_eq_k1]; exact i_ne_j.symm
        by_cases j = k2
        . next j_eq_k2 =>
          rw [← j_eq_k2, hj, ← bi_eq_bj, bi_eq_true] at h2
          simp only [Prod.mk.injEq, and_false] at h2
        . next j_ne_k2 =>
          specialize h5 j j_ne_k1 j_ne_k2
          rw [hj, li_eq_lj] at h5
          simp (config := { decide := true }) only at h5
      . next i_ne_k1 =>
        by_cases i = k2
        . next i_eq_k2 =>
          rw [← i_eq_k2, hi, bi_eq_true] at h2
          simp only [Prod.mk.injEq, and_false] at h2
        . next i_ne_k2 =>
          specialize h5 i i_ne_k1 i_ne_k2
          rw [hi] at h5
          simp only [not_true] at h5
    . next bi_eq_false =>
      simp only [Bool.not_eq_true] at bi_eq_false
      by_cases i = k2
      . next i_eq_k2 =>
        have j_ne_k2 : j ≠ k2 := by rw [← i_eq_k2]; exact i_ne_j.symm
        by_cases j = k1
        . next j_eq_k1 =>
          rw [← j_eq_k1, hj, ← bi_eq_bj, bi_eq_false] at h1
          simp only [Prod.mk.injEq, and_false] at h1
        . next j_ne_k1 =>
          specialize h5 j j_ne_k1 j_ne_k2
          rw [hj, li_eq_lj] at h5
          simp (config := { decide := true }) only at h5
      . next i_ne_k2 =>
        by_cases i = k1
        . next i_eq_k1 =>
          rw [← i_eq_k1, hi, bi_eq_false] at h1
          simp only [Prod.mk.injEq, and_false] at h1
        . next i_ne_k1 =>
          specialize h5 i i_ne_k1 i_ne_k2
          rw [hi] at h5
          simp only [not_true] at h5

theorem clear_insertRat_base_case {n : Nat} (f : DefaultFormula n) (hf : f.ratUnits = #[] ∧ f.assignments.size = n)
  (units : List (Literal (PosFin n))) :
  let insertRat_res := insertRatUnits f units
  clear_insert_induction_motive f hf.2 insertRat_res.1.ratUnits 0 insertRat_res.1.assignments := by
  have insertRatUnits_assignments_size := insertRatUnits_preserves_assignments_size f units
  rw [hf.2] at insertRatUnits_assignments_size
  apply Exists.intro insertRatUnits_assignments_size
  intro i
  simp only [Nat.zero_le, getElem_fin, ne_eq, forall_const, true_and]
  exact insertRatUnits_postcondition f hf units i

theorem clear_insertRat {n : Nat} (f : DefaultFormula n) (hf : f.ratUnits = #[] ∧ f.assignments.size = n)
  (units : List (Literal (PosFin n))) : clearRatUnits (f.insertRatUnits units).1 = f := by
  simp only [clearRatUnits]
  ext
  . simp only [insertRatUnits]
  . simp only [insertRatUnits]
  . rw [hf.1]
  . simp only
    let motive := clear_insert_induction_motive f hf.2 (insertRatUnits f units).1.ratUnits
    have h_base : motive 0 (insertRatUnits f units).1.assignments := clear_insertRat_base_case f hf units
    have h_inductive (idx : Fin (insertRatUnits f units).1.ratUnits.size) (assignments : Array Assignment)
      (ih : motive idx.val assignments) : motive (idx.val + 1) (clearUnit assignments (insertRatUnits f units).1.ratUnits[idx]) :=
      clear_insert_inductive_case f hf.2 (insertRatUnits f units).1.ratUnits
        (insertRatUnits_nodup f hf units) idx assignments ih
    rcases Array.foldl_induction motive h_base h_inductive with ⟨h_size, h⟩
    apply Array.ext
    . rw [h_size, hf.2]
    . intro i hi1 hi2
      have i_lt_n : i < n := by rw [← hf.2]; exact hi2
      specialize h ⟨i, i_lt_n⟩
      rcases h with h | h | h
      . exact h.1
      . exfalso
        rcases h with ⟨j, b, i_gt_zero, j_size, h⟩
        exact Nat.not_lt_of_le j_size j.2
      . exfalso
        rcases h with ⟨j1, j2, i_gt_zero, j1_size, h⟩
        exact Nat.not_lt_of_le j1_size j1.2

theorem performRatCheck_preserves_formula {n : Nat} (f : DefaultFormula n) (hf : f.ratUnits = #[] ∧ f.assignments.size = n)
  (p : Literal (PosFin n)) (ratHint : Nat × Array Nat) : (performRatCheck f p ratHint).1 = f := by
  simp only [performRatCheck, Bool.or_eq_true, Bool.not_eq_true']
  split
  . next c heq =>
    split
    . rw [clear_insertRat f hf]
    . let fc := (insertRatUnits f (negate (DefaultClause.delete c p))).1
      have fc_assignments_size : fc.assignments.size = n := by rw [insertRatUnits_preserves_assignments_size, hf.2]
      have insertRatUnits_rw : (insertRatUnits f (negate (DefaultClause.delete c p))).1 =
        ⟨(insertRatUnits f (negate (DefaultClause.delete c p))).1.clauses,
         (insertRatUnits f (negate (DefaultClause.delete c p))).1.rupUnits,
         (insertRatUnits f (negate (DefaultClause.delete c p))).1.ratUnits,
         (insertRatUnits f (negate (DefaultClause.delete c p))).1.assignments⟩ := by rfl
      simp only [performRupCheck_preserves_clauses, performRupCheck_preserves_rupUnits, performRupCheck_preserves_ratUnits]
      rw [restoreAssignments_performRupCheck fc fc_assignments_size ratHint.2, ← insertRatUnits_rw,
        clear_insertRat f hf (negate (DefaultClause.delete c p))]
      split
      . rfl
      . rfl
  . rfl

theorem performRatCheck_fold_preserves_formula {n : Nat} (f : DefaultFormula n) (hf : f.ratUnits = #[] ∧ f.assignments.size = n)
  (p : Literal (PosFin n)) (ratHints : Array (Nat × Array Nat)) :
  let performRatCheck_fold_res :=
    ratHints.foldl
      (fun x ratHint =>
        if x.2 = true then performRatCheck x.1 p ratHint
        else (x.1, false)) (f, true) 0 ratHints.size
  performRatCheck_fold_res.1 = f := by
  let motive (idx : Nat) (acc : DefaultFormula n × Bool) := acc.1 = f
  have h_base : motive 0 (f, true) := by rfl
  have h_inductive (idx : Fin ratHints.size) (acc : DefaultFormula n × Bool) :
    motive idx.1 acc → motive (idx.1 + 1) (if acc.2 then performRatCheck acc.1 p ratHints[idx] else (acc.1, false)) := by
    intro ih
    rw [ih]
    split
    . exact performRatCheck_preserves_formula f hf p ratHints[idx]
    . rfl
  exact Array.foldl_induction motive h_base h_inductive

theorem ratAdd_result {n : Nat} (f : DefaultFormula n) (c : DefaultClause n) (p : Literal (PosFin n))
  (rupHints : Array Nat) (ratHints : Array (Nat × Array Nat)) (f' : DefaultFormula n)
  (f_readyForRatAdd : readyForRatAdd f) (pc : p ∈ Clause.toList c)
  (ratAddSuccess : performRatAdd f c p rupHints ratHints = (f', true)) : f' = insert f c := by
  rw [performRatAdd] at ratAddSuccess
  simp only [Bool.not_eq_true'] at ratAddSuccess
  split at ratAddSuccess
  . split at ratAddSuccess
    . simp only [Prod.mk.injEq, and_false] at ratAddSuccess
    . split at ratAddSuccess
      . simp only [Prod.mk.injEq, and_false] at ratAddSuccess
      . split at ratAddSuccess
        . simp only [Prod.mk.injEq, and_false] at ratAddSuccess
        . split at ratAddSuccess
          . simp only [Prod.mk.injEq, and_false] at ratAddSuccess
          . next performRatCheck_fold_success =>
            simp only [Bool.not_eq_false] at performRatCheck_fold_success
            let fc := (insertRupUnits f (negate c)).1
            have fc_assignments_size : (insertRupUnits f (negate c)).1.assignments.size = n := by
              rw [insertRupUnits_preserves_assignments_size f (negate c)]
              exact f_readyForRatAdd.2.2.1
            simp only [performRupCheck_preserves_clauses, performRupCheck_preserves_rupUnits, performRupCheck_preserves_ratUnits,
              restoreAssignments_performRupCheck fc fc_assignments_size, Prod.mk.injEq, and_true] at ratAddSuccess
            rw [← ratAddSuccess]
            clear f' ratAddSuccess
            let performRupCheck_res := (performRupCheck (insertRupUnits f (negate c)).1 rupHints).1
            have h_performRupCheck_res : performRupCheck_res.ratUnits = #[] ∧ performRupCheck_res.assignments.size = n := by
              have hsize : performRupCheck_res.assignments.size = n := by
                rw [performRupCheck_preserves_assignments_size, insertRupUnits_preserves_assignments_size, f_readyForRatAdd.2.2.1]
              exact And.intro f_readyForRatAdd.1 hsize
            have insertRupUnits_rw : (insertRupUnits f (negate c)).1 =
              ⟨(insertRupUnits f (negate c)).1.clauses, (insertRupUnits f (negate c)).1.rupUnits,
               (insertRupUnits f (negate c)).1.ratUnits, (insertRupUnits f (negate c)).1.assignments⟩ := by rfl
            simp only [performRatCheck_fold_preserves_formula performRupCheck_res h_performRupCheck_res (negateLiteral p) ratHints,
              performRupCheck_preserves_clauses, performRupCheck_preserves_rupUnits, performRupCheck_preserves_ratUnits,
              restoreAssignments_performRupCheck fc fc_assignments_size, ← insertRupUnits_rw,
              clear_insertRup f f_readyForRatAdd.2 (negate c)]
  . simp only [Prod.mk.injEq, and_false] at ratAddSuccess

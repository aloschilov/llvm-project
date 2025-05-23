// RUN: %clang_cc1 -fopenmp -triple powerpc64le-unknown-unknown -fopenmp-targets=powerpc64le-ibm-linux-gnu -debug-info-kind=limited -emit-llvm %s -o - | FileCheck %s --check-prefix DEBUG
// RUN: %clang_cc1 -fopenmp -triple powerpc64le-unknown-unknown -fopenmp-targets=powerpc64le-ibm-linux-gnu -emit-llvm %s -o - | FileCheck %s --check-prefix CHECK
#ifndef HEADER
#define HEADER

// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";d;{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";i;{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";i[1:23];{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";p;{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";p[1:24];{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";s;{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";s.i;{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";s.s.f;{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";s.p[:22];{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";s.ps->s.i;{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";s.ps->ps;{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";s.ps->ps->ps;{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";s.ps->ps->s.f[:22];{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";ps;{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";ps->i;{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";ps->s.f;{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";ps->p[:22];{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";ps->ps->s.i;{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";ps->ps->ps;{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";ps->ps->ps->ps;{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";ps->ps->ps->s.f[:22];{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";s.f[:22];{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";s.p[:33];{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";ps->p[:33];{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";s.s;{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"

struct S1 {
    int i;
    float f[50];
};

struct S2 {
    int i;
    float f[50];
    S1 s;
    double *p;
    struct S2 *ps;
};

void foo() {
  double d;
  int i[100];
  float *p;

  S2 s;
  S2 *ps;

  [[omp::directive(target map(d))]]
  { }
  [[omp::directive(target map(i))]]
  { }
  [[omp::directive(target map(i[1:23]))]]
  { }
  [[omp::directive(target map(p))]]
  { }
  [[omp::directive(target map(p[1:24]))]]
  { }
  [[omp::directive(target map(s))]]
  { }
  [[omp::directive(target map(s.i))]]
  { }
  [[omp::directive(target map(s.s.f))]]
  { }
  [[omp::directive(target map(s.p))]]
  { }
  [[omp::directive(target map(to: s.p[:22]))]]
  { }
  [[omp::directive(target map(s.ps))]]
  { }
  [[omp::directive(target map(from: s.ps->s.i))]]
  { }
  [[omp::directive(target map(to: s.ps->ps))]]
  { }
  [[omp::directive(target map(s.ps->ps->ps))]]
  { }
  [[omp::directive(target map(to: s.ps->ps->s.f[:22]))]]
  { }
  [[omp::directive(target map(ps))]]
  { }
  [[omp::directive(target map(ps->i))]]
  { }
  [[omp::directive(target map(ps->s.f))]]
  { }
  [[omp::directive(target map(from: ps->p))]]
  { }
  [[omp::directive(target map(to: ps->p[:22]))]]
  { }
  [[omp::directive(target map(ps->ps))]]
  { }
  [[omp::directive(target map(from: ps->ps->s.i))]]
  { }
  [[omp::directive(target map(from: ps->ps->ps))]]
  { }
  [[omp::directive(target map(ps->ps->ps->ps))]]
  { }
  [[omp::directive(target map(to: ps->ps->ps->s.f[:22]))]]
  { }
  [[omp::directive(target map(to: s.f[:22]) map(from: s.p[:33]))]]
  { }
  [[omp::directive(target map(from: s.f[:22]) map(to: ps->p[:33]))]]
  { }
  [[omp::directive(target map(from: s.f[:22], s.s) map(to: ps->p[:33]))]]
  { }
}

// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";B;{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";unknown;unknown;0;0;;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";A;{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";x;{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";fn;{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";s;{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"
// DEBUG: @{{.+}} = private constant [7 x ptr] [ptr @{{[0-9]+}}, ptr @{{[0-9]+}}, ptr @{{[0-9]+}}, ptr @{{[0-9]+}}, ptr @{{[0-9]+}}, ptr @{{[0-9]+}}, ptr @{{[0-9]+}}]

void bar(int N) {
  double B[10];
  double A[N];
  double x;
  S1 s;
  auto fn = [&x]() { return x; };
  [[omp::directive(target)]]
  {
    (void)B;
    (void)A;
    (void)fn();
    (void)s.f;
  }
}

// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";t;{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"

[[omp::directive(declare target)]];
double t;
[[omp::directive(end declare target)]];

void baz() {
  [[omp::directive(target map(to:t))]]
  { }
  [[omp::directive(target map(to:t) nowait)]]
  { }
  [[omp::directive(target teams map(to:t))]]
  { }
  [[omp::directive(target teams map(to:t) nowait)]]
  { }
  [[omp::directive(target data map(to:t))]]
  { }
  [[omp::sequence(directive(target enter data map(to:t)),
                  directive(target enter data map(to:t) nowait),
                  directive(target exit data map(from:t)),
                  directive(target exit data map(from:t) nowait),
                  directive(target update from(t)),
                  directive(target update to(t)),
                  directive(target update from(t) nowait),
                  directive(target update to(t) nowait))]];
}

struct S3 {
  double Z[64];
};

[[omp::directive(declare mapper(id: S3 s) map(s.Z[0:64]))]]
void qux() {
  S3 s;
  [[omp::directive(target map(mapper(id), to:s))]]
  { }
}

// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";s.Z[0:64];{{.*}}.cpp;{{[0-9]+}};{{[0-9]+}};;\00"

// Clang used to mistakenly generate the map name "x" for both x and y on this
// directive.  Conditions to reproduce the bug: a single map clause has two
// variables, and at least the second is used in the associated statement.
//
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";x;{{.*}}.cpp;[[@LINE+3]];7;;\00"
// DEBUG: @{{[0-9]+}} = private unnamed_addr constant [{{[0-9]+}} x i8] c";y;{{.*}}.cpp;[[@LINE+2]];10;;\00"
void secondMapNameInClause() {
  int x, y;
  [[omp::directive(target map(to: x, y))]];
  x = y = 1;
}

// DEBUG: store ptr @[[NAME:.offload_mapnames.[0-9]+]], ptr %[[ARG:.+]]
// CHECK-NOT: store ptr @[[NAME:.offload_mapnames.[0-9]+]], ptr %[[ARG:.+]]

// DEBUG: void @.omp_mapper._ZTS2S3.id(ptr {{.*}}, ptr {{.*}}, ptr {{.*}}, i64 {{.*}}, i64 {{.*}}, ptr noundef [[MAPPER_NAME:%.+]])
// DEBUG: call void @__tgt_push_mapper_component(ptr %{{.*}}, ptr %{{.*}}, ptr %{{.*}}, i64 %{{.*}}, i64 %{{.*}}, ptr [[MAPPER_NAME]])

#endif


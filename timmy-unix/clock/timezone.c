#include <assert.h>
#include <time.h>

#include <caml/alloc.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>

static
void
check_tuple(value tuple, int size)
{
  assert(Is_block(tuple) && Tag_val(tuple) == 0 && Wosize_val(tuple) == size);
}

static
int
check_int(value n)
{
  assert(Is_long(n));
  return Int_val(n);
}

static
int
offset(const time_t time)
{
  struct tm localtime;
  localtime_r(&time, &localtime);
  return localtime.tm_gmtoff;
}

CAMLprim
value
ocaml_timmy_offset_timestamp_s(value datetime)
{
  CAMLparam1(datetime);
  const time_t time = Int64_val(datetime);

  CAMLreturn(Val_int (offset(time)));
}

CAMLprim
value
ocaml_timmy_offset_calendar_time_s(value date, value daytime)
{
  CAMLparam2(date, daytime);
  check_tuple(date, 3);
  check_tuple(daytime, 3);

  const int year = check_int(Field(date, 0));
  const int month = check_int(Field(date, 1));
  const int day = check_int(Field(date, 2));
  const int hours = check_int(Field(daytime, 0));
  const int minutes = check_int(Field(daytime, 1));
  const int seconds = check_int(Field(daytime, 2));

  struct tm datetime = {
    .tm_sec = seconds,
    .tm_min = minutes,
    .tm_hour = hours,
    .tm_mday = day,
    .tm_mon = month - 1,
    .tm_year = year - 1900
  };
  time_t time = mktime(&datetime);
  CAMLreturn(Val_int(offset(time)));
}

CAMLprim
value
ocaml_timmy_local_timezone_name()
{
  CAMLparam0();
  const time_t now = time(NULL);
  struct tm localtime;
  localtime_r(&now, &localtime);
  CAMLreturn(caml_copy_string (localtime.tm_zone));
}

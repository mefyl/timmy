#include <chrono>

#include <assert.h>
#include <string>
#include <time.h>

#include <caml/alloc.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>

std::string current_zone_name(void)
{
  auto current_zone = std::chrono::current_zone();
  return std::string(current_zone->name());
}

int offset(const std::chrono::sys_time<std::chrono::seconds>& tp)
{
  auto current_zone = std::chrono::current_zone();
  auto sys_info = current_zone->get_info(tp);
  return sys_info.offset.count();
}

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

extern "C" {

CAMLprim
value
ocaml_timmy_offset_timestamp_s(value datetime)
{
  CAMLparam1(datetime);

  const auto utctime = std::chrono::sys_time<std::chrono::seconds>(
    std::chrono::seconds(Int64_val(datetime))
  );
  CAMLreturn(Val_int (offset(utctime)));
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

  const auto time = std::chrono::sys_time<std::chrono::seconds>(
    std::chrono::seconds(mktime(&datetime))
  );
  CAMLreturn(Val_int(offset(time)));
}

CAMLprim
value
ocaml_timmy_local_timezone_name()
{
  CAMLparam0();
  auto name = current_zone_name();
  CAMLreturn(caml_copy_string (name.data()));
}
}

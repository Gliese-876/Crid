# Library decisions

This project targets Flutter stable 3.41.9 and Dart 3.11.5.

## Locked first-version stack

| Capability | Package | Decision |
|---|---|---|
| State management | `flutter_riverpod` | Mature Flutter state-management package. Used at the app boundary so UI does not talk directly to persistence. |
| Routing | `go_router` | Mature Flutter router with declarative route definitions and deep-link friendly structure. |
| SQLite ORM | `drift`, `sqlite3_flutter_libs`, `path_provider` | Drift provides typed schema and generated accessors. SQLite platform bits stay isolated below repository/service APIs. |
| File picker | `file_picker` | Mature cross-platform picker for Android and Windows import/export flows. |
| Notifications | `flutter_local_notifications` | Supports Android and Windows through platform implementations. Wrapped by reminder services. |
| HTML parsing | `html` | Pure Dart parser for HTML-table `.xls` files. Decoding is kept in import adapters. |
| GBK decoding | `charset` | Used only at the file decoding boundary for legacy HTML `.xls` samples. |
| BIFF `.xls` decoding | `spreadsheet_decoder` behind adapter | Attempted through `BiffXlsParserAdapter`. Any unsupported behavior must stay isolated and covered by sample regression tests. |
| iCalendar/RRULE | `icalendar_parser`, `rrule`, `timezone` | Used behind ICS import/export services; app domain models remain independent of package-specific objects. |

## Adapter boundaries

Course import formats are treated as product-specific and risky. Parsers must produce `ParsedTimetable` and warnings instead of writing directly to the formal timetable. The merge engine decides whether parsed records are inserted, skipped, diffed, or surfaced as conflicts.

BIFF `.xls` is the highest-risk format. The first version may support the provided sample and common spreadsheet rows, but the adapter should remain replaceable if a more reliable parser is later adopted.

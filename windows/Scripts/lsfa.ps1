$search = $args[0].Trim()
if ($search.Contains("*")) {
  dir -r -n | where { $_ -ilike $search }
} else {
  dir -r -n | where { $_ -imatch $search }
}

ardour {
  ["type"]    = "EditorAction",
  name        = "Punch Around",
  author      = "Patterns Pandemic",
  description = "Configure the punch around the current playhead."
}

function factory (unused_params)
  return function ()

    local sample_rate = 48000 --from Jack
    local playhead = Session:transport_sample()
    local tempo_map = Session:tempo_map()
    local tempo_section = tempo_map:tempo_section_at_sample(playhead)
    local meter_section = tempo_map:meter_section_at_sample(playhead)
    local tempo = tempo_section:to_tempo()
    local meter = meter_section:to_meter()
    local divisions_per_bar = meter:divisions_per_bar()
    local quarter_note_samples = tempo:samples_per_quarter_note(sample_rate)
    local samples_per_bar = divisions_per_bar * quarter_note_samples

    -- Check for marker defined padding size.
    local bar_padding = 2.0 --default
    local padding_size = nil
    local mark = Session:locations():mark_at(playhead, 0)
    if mark then
      local mark_name = mark:name()
      _, _, padding_size = string.find(mark_name, "<(%d)>")
      padding_size = math.tointeger(padding_size)
    end
    if padding_size ~= nil then
      bar_padding = padding_size
    end

    local punch_padding = math.floor(bar_padding * samples_per_bar)
    local punch_in = playhead - punch_padding
    local punch_out = playhead + punch_padding

    if punch_in < 0 then punch_in = 0 end

    Editor:set_punch_range(punch_in, punch_out, "Punch Around")

  end
end

% 中文配置
interfaces.implement {
  name      = "ChtYear",
  public    = true,
  arguments = "string",
  actions   = function(y)
    local n = tonumber(y)
    local s = ""
    s="西元"
    if n == 1 then
      s=s.."元"
    end
    else
      if n < 0 then
        s=s.."前"
        n = -n
      end
      local cap = {
        ["0"] = "零",
        ["1"] = "壹",
        ["2"] = "贰",
        ["3"] = "叁",
        ["4"] = "肆",
        ["5"] = "伍",
        ["6"] = "陆",
        ["7"] = "柒",
        ["8"] = "捌",
        ["9"] = "玖",
      }
      ss, p = string.gsub(
        string.format("%d",n),
        "(.)", function(s) return cap[s] end)
      s = s..ss
    end
    s=s.."年"

    context(s)
  end
}

interfaces.implement {
  name      = "ChtMonth",
  public    = true,
  arguments = "string",
  actions   = function(m)
    local n = tonumber(m)
    local cap = {
      ["1"] = "壹",
      ["2"] = "贰",
      ["3"] = "叁",
      ["4"] = "肆",
      ["5"] = "伍",
      ["6"] = "陆",
      ["7"] = "柒",
      ["8"] = "捌",
      ["9"] = "玖",
      ["10"] = "拾",
      ["11"] = "拾壹",
      ["12"] = "拾贰",
    }
    context(cap[n].."月")
  end
}

interfaces.implement {
  name      = "ChtDay",
  public    = true,
  arguments = "string",
  actions   = function(d)
    local n = tonumber(d)
    local cap = {
      ["1"] = "壹",
      ["2"] = "贰",
      ["3"] = "叁",
      ["4"] = "肆",
      ["5"] = "伍",
      ["6"] = "陆",
      ["7"] = "柒",
      ["8"] = "捌",
      ["9"] = "玖",
    }
    if n > 30 then
      s="卅"..cap[n%10]
    else if n == 30 then
      s="叁拾"
    elseif n > 20 then
      s="廿"..cap[n%10]
    elseif n == 20 then
      s="貳拾"
    elseif n > 10 then
      s="拾"..cap[n%10]
    else
      s=cap[n]
    end
    context(s.."日")
  end
}

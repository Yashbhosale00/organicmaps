#include "base/base.hpp"

#include "base/assert.hpp"
#include "base/exception.hpp"
#include "base/logging.hpp"
#include "base/src_point.hpp"

#include <iostream>

namespace base
{
bool OnAssertFailedDefault(SrcPoint const & srcPoint, std::string const & msg)
{
  auto & logger = LogHelper::Instance();

  std::cerr << "TID(" << logger.GetThreadID() << ") ASSERT FAILED" << std::endl
            << srcPoint.FileName() << ":" << srcPoint.Line() << std::endl
            << msg << std::endl;
  return true;
}

AssertFailedFn OnAssertFailed = &OnAssertFailedDefault;

AssertFailedFn SetAssertFunction(AssertFailedFn fn)
{
  std::swap(OnAssertFailed, fn);
  return fn;
}
}  // namespace base

#pragma once

#include "generator/feature_builder.hpp"
#include "generator/generate_info.hpp"
#include "generator/routing_helpers.hpp"

namespace generator
{
namespace tests_support
{

bool MakeFakeBordersFile(std::string const & intemediatePath, std::string const & fileName);

class TestRawGenerator
{
  feature::GenerateInfo m_genInfo;
  std::string const & GetTmpPath() const { return m_genInfo.m_cacheDir; }

public:
  TestRawGenerator();
  ~TestRawGenerator();

  void SetupTmpFolder(std::string const & tmpPath);

  void BuildFB(std::string const & osmFilePath, std::string const & mwmName);
  void BuildFeatures(std::string const & mwmName);
  void BuildSearch(std::string const & mwmName);
  void BuildRouting(std::string const & mwmName, std::string const & countryName);

  routing::FeatureIdToOsmId LoadFID2OsmID(std::string const & mwmName);

  template <class FnT> void ForEachFB(std::string const & mwmName, FnT && fn)
  {
    using namespace feature;
    ForEachFeatureRawFormat(m_genInfo.GetTmpFileName(mwmName), [&fn](FeatureBuilder const & fb, uint64_t)
    {
      fn(fb);
    });
  }

  std::string GetMwmPath(std::string const & mwmName) const;
  std::string GetCitiesBoundariesPath() const;

  feature::GenerateInfo const & GetGenInfo() const { return m_genInfo; }
  bool IsWorld(std::string const & mwmName) const;
};

} // namespace tests_support
} // namespace generator

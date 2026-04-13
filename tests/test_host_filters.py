"""Unit tests for filter_plugins/host_filters.py."""

import sys
import os
import pytest

# Add filter_plugins to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'filter_plugins'))

from host_filters import (
    parse_asset_hostname,
    asset_id,
    group_code,
    asset_type,
    filter_by_group_range,
    filter_by_label,
    matches_pattern,
    matches_regex,
    has_service,
    filter_by_platform,
)


class TestParseAssetHostname:
    """Tests for parse_asset_hostname()."""

    def test_valid_fqdn(self):
        result = parse_asset_hostname("0046-20.cloud.bauer-group.com")
        assert result["valid"] is True
        assert result["asset_id"] == "0046"
        assert result["group_code"] == "20"
        assert result["asset_type"] == "public_cloud_vm"

    def test_valid_short(self):
        result = parse_asset_hostname("0046-20")
        assert result["valid"] is True
        assert result["asset_id"] == "0046"
        assert result["group_code"] == "20"

    def test_invalid_hostname(self):
        result = parse_asset_hostname("invalid-host")
        assert result["valid"] is False
        assert result["asset_id"] is None

    def test_empty_string(self):
        result = parse_asset_hostname("")
        assert result["valid"] is False

    def test_unknown_group_code(self):
        result = parse_asset_hostname("0001-99")
        assert result["valid"] is True
        assert result["asset_type"] == "unknown_99"

    def test_all_known_group_codes(self):
        known_codes = ["00", "05", "10", "15", "20", "25", "30", "35",
                       "40", "45", "48", "50", "55", "60", "61", "68",
                       "70", "71", "72", "78", "80", "85", "88"]
        for code in known_codes:
            result = parse_asset_hostname(f"0001-{code}")
            assert result["valid"] is True
            assert not result["asset_type"].startswith("unknown_"), \
                f"Group code {code} should be known"


class TestConvenienceFilters:
    """Tests for asset_id(), group_code(), asset_type()."""

    def test_asset_id(self):
        assert asset_id("0047-20.cloud.bauer-group.com") == "0047"

    def test_asset_id_invalid(self):
        assert asset_id("invalid") == ""

    def test_group_code(self):
        assert group_code("0047-20.cloud.bauer-group.com") == "20"

    def test_group_code_invalid(self):
        assert group_code("invalid") == ""

    def test_asset_type(self):
        assert asset_type("0047-20.cloud.bauer-group.com") == "public_cloud_vm"

    def test_asset_type_physical(self):
        assert asset_type("0001-00.cloud.bauer-group.com") == "physical_server"

    def test_asset_type_invalid(self):
        assert asset_type("invalid") == ""


class TestFilterByGroupRange:
    """Tests for filter_by_group_range()."""

    HOSTS = [
        "0001-00.cloud.bauer-group.com",
        "0002-10.cloud.bauer-group.com",
        "0003-20.cloud.bauer-group.com",
        "0004-25.cloud.bauer-group.com",
        "0005-30.cloud.bauer-group.com",
    ]

    def test_single_code(self):
        result = filter_by_group_range(self.HOSTS, 20, 20)
        assert len(result) == 1
        assert "0003-20" in result[0]

    def test_range(self):
        result = filter_by_group_range(self.HOSTS, 20, 29)
        assert len(result) == 2

    def test_all(self):
        result = filter_by_group_range(self.HOSTS, 0, 99)
        assert len(result) == 5

    def test_none_matching(self):
        result = filter_by_group_range(self.HOSTS, 50, 59)
        assert len(result) == 0

    def test_empty_list(self):
        result = filter_by_group_range([], 0, 99)
        assert len(result) == 0


class TestFilterByLabel:
    """Tests for filter_by_label()."""

    HOSTVARS = {
        "host-a": {"labels": ["production", "web"]},
        "host-b": {"labels": ["production", "db"]},
        "host-c": {"labels": ["staging"]},
        "host-d": {},
    }

    def test_matching_label(self):
        hosts = list(self.HOSTVARS.keys())
        result = filter_by_label(hosts, "production", self.HOSTVARS)
        assert len(result) == 2

    def test_no_match(self):
        hosts = list(self.HOSTVARS.keys())
        result = filter_by_label(hosts, "nonexistent", self.HOSTVARS)
        assert len(result) == 0

    def test_host_without_labels(self):
        result = filter_by_label(["host-d"], "production", self.HOSTVARS)
        assert len(result) == 0


class TestPatternMatching:
    """Tests for matches_pattern() and matches_regex()."""

    def test_wildcard_match(self):
        assert matches_pattern("0046-20.cloud.bauer-group.com", "*.bauer-group.com")

    def test_wildcard_no_match(self):
        assert not matches_pattern("other.example.com", "*.bauer-group.com")

    def test_regex_match(self):
        assert matches_regex("0046-20.cloud.bauer-group.com", r"^\d{4}-\d{2}\.")

    def test_regex_no_match(self):
        assert not matches_regex("invalid", r"^\d{4}-\d{2}\.")


class TestHasService:
    """Tests for has_service()."""

    def test_service_present(self):
        assert has_service(["nginx", "docker"], "docker")

    def test_service_absent(self):
        assert not has_service(["nginx"], "docker")

    def test_empty_list(self):
        assert not has_service([], "docker")

    def test_none(self):
        assert not has_service(None, "docker")


class TestFilterByPlatform:
    """Tests for filter_by_platform()."""

    HOSTVARS = {
        "host-a": {"platform": "ubuntu_2404"},
        "host-b": {"platform": "ubuntu_2204"},
        "host-c": {"platform": "debian_12"},
        "host-d": {},
    }

    def test_exact_match(self):
        hosts = list(self.HOSTVARS.keys())
        result = filter_by_platform(hosts, "ubuntu_2404", self.HOSTVARS)
        assert len(result) == 1

    def test_wildcard_match(self):
        hosts = list(self.HOSTVARS.keys())
        result = filter_by_platform(hosts, "ubuntu_*", self.HOSTVARS)
        assert len(result) == 2

    def test_no_match(self):
        hosts = list(self.HOSTVARS.keys())
        result = filter_by_platform(hosts, "rhel_*", self.HOSTVARS)
        assert len(result) == 0

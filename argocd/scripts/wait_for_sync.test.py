import requests
import unittest
import json
from unittest import mock
from wait_for_sync import is_cluster_insync
from os import path

fixturespath = path.dirname(__file__) + "/test-fixtures/"


class MockResponse:
    def __init__(self, json_data, status_code):
        self.json_data = json_data
        self.status_code = status_code
    def json(self):
        return self.json_data

class TestStringMethods(unittest.TestCase):


    @mock.patch('requests.get')
    def test_bitly(self, mock_get):
        mockres = MockResponse(None, 404);
        mock_get.return_value = mockres
        res = is_cluster_insync("fake-url", "fake-token", "default", "git-hash")
        self.assertEqual(res, False)

    @mock.patch('requests.get')
    def test_outofsync(self, mock_get):

        with open(f'{fixturespath}/test.out-of-sync.json') as json_file:
            data = json.load(json_file)

            mockres = MockResponse(data, 200);
            mock_get.return_value = mockres
            res = is_cluster_insync("fake-url", "fake-token", "default", "140c6627d2ea1ac683770accbd0adb8700c51d58")
            self.assertEqual(res, False)


    @mock.patch('requests.get')
    def test_only_needs_prune(self, mock_get):

        with open(f'{fixturespath}/test.prune.json') as json_file:
            data = json.load(json_file)

            mockres = MockResponse(data, 200);
            mock_get.return_value = mockres
            res = is_cluster_insync("fake-url", "fake-token", "default", "140c6627d2ea1ac683770accbd0adb8700c51d58")
            self.assertEqual(res, True)

    @mock.patch('requests.get')
    def test_in_sync(self, mock_get):

        with open(f'{fixturespath}/test.synced.json') as json_file:
            data = json.load(json_file)

            mockres = MockResponse(data, 200);
            mock_get.return_value = mockres
            res = is_cluster_insync("fake-url", "fake-token", "default", "11368bf4ef87b51b8a3a0242bb2979d01f70de01")
            self.assertEqual(res, True)

    @mock.patch('requests.get')
    def test_in_sync_to_different_target(self, mock_get):

        with open(f'{fixturespath}/test.synced.json') as json_file:
            data = json.load(json_file)

            mockres = MockResponse(data, 200);
            mock_get.return_value = mockres
            
            res = is_cluster_insync("https://fake.url", "fake-token", "default", "734713bc047d87bf7eac9674765ae793478c50d3")
            
            self.assertEqual(res, False)
            mock_get.assert_called_with('https://fake.url/api/v1/applications/default', headers={ 'Authorization' : 'Bearer fake-token' }, timeout = 10, verify=True)

if __name__ == '__main__':
    unittest.main()
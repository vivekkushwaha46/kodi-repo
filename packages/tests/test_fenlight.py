import sys
from unittest.mock import MagicMock
import os
import unittest
import json

# Mock Kodi Modules
sys.modules['xbmc'] = MagicMock()
sys.modules['xbmcgui'] = MagicMock()
sys.modules['xbmcplugin'] = MagicMock()
sys.modules['xbmcaddon'] = MagicMock()
sys.modules['xbmcvfs'] = MagicMock()

window_mock = MagicMock()
window_mock.getProperty.return_value = 'false'
sys.modules['xbmcgui'].Window.return_value = window_mock

# Add addon path to sys.path
ADDON_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__line__ if '__file__' not in globals() else __file__)))
LIB_DIR = os.path.join(ADDON_DIR, 'resources', 'lib')
sys.path.insert(0, LIB_DIR)

from scrapers.external import _process_duplicates

class TestFenLightOptimizations(unittest.TestCase):
	def test_scrapers_duplicate_removal(self):
		# Create mock scraping results with duplicates
		test_hash = '1A2B3C'
		results = [
			{'hash': test_hash, 'quality': '1080p', 'size': 1000},
			{'hash': test_hash, 'quality': '1080p', 'size': 1000},
			{'hash': test_hash, 'quality': '1080p', 'size': 1000},
			{'hash': '9Z8Y7X', 'quality': '4K', 'size': 5000}
		]
		processed = list(_process_duplicates(results))
		# Should only have 2 unique hashes
		self.assertEqual(len(processed), 2)
		self.assertEqual(processed[0]['hash'], test_hash)
		self.assertEqual(processed[1]['hash'], '9Z8Y7X')
		print('Scraper deduplication is working efficiently.')

if __name__ == '__main__':
	unittest.main()

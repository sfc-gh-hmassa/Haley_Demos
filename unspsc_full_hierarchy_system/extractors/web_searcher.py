"""
Web Searcher for Product Intelligence Gathering

Uses DuckDuckGo search to gather product information based on
extracted brand names, serial numbers, and model numbers.
"""

import time
from typing import List, Dict, Optional
from dataclasses import dataclass, field

@dataclass
class SearchResult:
    """Container for individual search result"""
    query: str
    title: str
    snippet: str
    url: str
    relevance_score: float = 0.0

@dataclass 
class ProductWebInfo:
    """Container for aggregated web search information about a product"""
    search_results: List[SearchResult] = field(default_factory=list)
    product_category: str = ""
    applications: List[str] = field(default_factory=list)
    specifications: List[str] = field(default_factory=list)
    confidence: str = "Low"

class WebSearcher:
    """
    Web searcher for gathering product intelligence using DuckDuckGo.
    
    Searches for extracted product identifiers to gather additional
    context and product information for enhanced classification.
    """
    
    def __init__(self, max_searches: int = 3, delay_between_searches: float = 0.5):
        """
        Initialize WebSearcher.
        
        Args:
            max_searches: Maximum number of searches to perform
            delay_between_searches: Delay between searches (seconds)
        """
        self.max_searches = max_searches
        self.delay_between_searches = delay_between_searches
        self._search_function = None
    
    def _get_search_function(self):
        """Get DuckDuckGo search function with proper setup"""
        if self._search_function is None:
            try:
                from duckduckgo_search import DDGS
                
                def search_ddg(query: str, max_results: int = 3) -> List[Dict]:
                    """Search using DuckDuckGo"""
                    results = []
                    try:
                        with DDGS() as ddgs:
                            for result in ddgs.text(query, max_results=max_results):
                                results.append({
                                    'title': result.get('title', ''),
                                    'snippet': result.get('body', ''),
                                    'url': result.get('href', '')
                                })
                    except Exception as e:
                        print(f"⚠️ DuckDuckGo search error: {e}")
                    return results
                
                self._search_function = search_ddg
                print("✅ DuckDuckGo search initialized")
                
            except ImportError:
                print("❌ DuckDuckGo search not available")
                print("💡 Install with: pip install duckduckgo-search")
                self._search_function = self._mock_search
        
        return self._search_function
    
    def _mock_search(self, query: str, max_results: int = 3) -> List[Dict]:
        """Mock search function when DuckDuckGo is not available"""
        return [{
            'title': f"Mock result for {query}",
            'snippet': f"This is a mock search result for the query: {query}. Install duckduckgo-search for real web search.",
            'url': f"https://example.com/mock-{query.replace(' ', '-')}"
        }]
    
    def search_product_info(self, search_terms: List[str]) -> ProductWebInfo:
        """
        Search for product information using the provided search terms.
        
        Args:
            search_terms: List of search terms (brands, models, serials)
            
        Returns:
            ProductWebInfo: Aggregated web search information
        """
        print(f"🌐 Searching web for product information...")
        print(f"   Search terms: {search_terms[:3]}...")  # Show first 3
        
        web_info = ProductWebInfo()
        search_function = self._get_search_function()
        
        # Limit the number of searches
        limited_search_terms = search_terms[:self.max_searches]
        
        for i, search_term in enumerate(limited_search_terms):
            if i > 0:
                time.sleep(self.delay_between_searches)
            
            try:
                print(f"   🔍 Searching: {search_term}")
                
                # Perform web search
                raw_results = search_function(search_term, max_results=3)
                
                # Convert to SearchResult objects
                for raw_result in raw_results:
                    search_result = SearchResult(
                        query=search_term,
                        title=raw_result.get('title', ''),
                        snippet=raw_result.get('snippet', ''),
                        url=raw_result.get('url', ''),
                        relevance_score=self._calculate_relevance(raw_result, search_term)
                    )
                    web_info.search_results.append(search_result)
                
            except Exception as e:
                print(f"   ❌ Search failed for '{search_term}': {e}")
                continue
        
        # Analyze results to extract product intelligence
        web_info = self._analyze_search_results(web_info)
        
        print(f"✅ Web search completed")
        print(f"   📄 Found {len(web_info.search_results)} results")
        if web_info.product_category:
            print(f"   📂 Product category: {web_info.product_category}")
        
        return web_info
    
    def _calculate_relevance(self, result: Dict, search_term: str) -> float:
        """Calculate relevance score for a search result"""
        title = result.get('title', '').lower()
        snippet = result.get('snippet', '').lower()
        search_term_lower = search_term.lower()
        
        score = 0.0
        
        # Score based on search term presence
        if search_term_lower in title:
            score += 0.5
        if search_term_lower in snippet:
            score += 0.3
        
        # Score based on technical keywords
        technical_keywords = ['specification', 'manual', 'datasheet', 'pump', 'valve', 'motor']
        for keyword in technical_keywords:
            if keyword in title or keyword in snippet:
                score += 0.1
        
        return min(score, 1.0)  # Cap at 1.0
    
    def _analyze_search_results(self, web_info: ProductWebInfo) -> ProductWebInfo:
        """
        Analyze search results to extract product intelligence.
        
        Args:
            web_info: Web info with search results
            
        Returns:
            ProductWebInfo: Enhanced with analyzed information
        """
        if not web_info.search_results:
            return web_info
        
        # Collect all text for analysis
        all_text = ""
        for result in web_info.search_results:
            all_text += f" {result.title} {result.snippet}"
        
        all_text = all_text.lower()
        
        # Identify product category
        categories = {
            'pump': ['pump', 'pumping', 'hydraulic pump'],
            'valve': ['valve', 'control valve', 'relief valve'],
            'motor': ['motor', 'electric motor', 'servo motor'],
            'sensor': ['sensor', 'transducer', 'detector'],
            'controller': ['controller', 'control system', 'plc'],
            'actuator': ['actuator', 'cylinder', 'linear actuator']
        }
        
        category_scores = {}
        for category, keywords in categories.items():
            score = sum(all_text.count(keyword) for keyword in keywords)
            if score > 0:
                category_scores[category] = score
        
        if category_scores:
            web_info.product_category = max(category_scores.items(), key=lambda x: x[1])[0]
            web_info.confidence = "High" if max(category_scores.values()) >= 3 else "Medium"
        
        # Extract applications
        application_keywords = ['industrial', 'manufacturing', 'automotive', 'aerospace', 'marine', 'medical']
        web_info.applications = [app for app in application_keywords if app in all_text]
        
        # Extract specifications (basic)
        if 'psi' in all_text or 'pressure' in all_text:
            web_info.specifications.append('pressure system')
        if 'gpm' in all_text or 'flow' in all_text:
            web_info.specifications.append('flow control')
        if 'hp' in all_text or 'horsepower' in all_text:
            web_info.specifications.append('motor driven')
        
        return web_info
    
    def create_enhanced_summary(self, original_description: str, web_info: ProductWebInfo) -> str:
        """
        Create enhanced product summary incorporating web search intelligence.
        
        Args:
            original_description: Original technical description
            web_info: Web search information
            
        Returns:
            str: Enhanced product summary
        """
        summary_parts = [original_description]
        
        if web_info.product_category:
            summary_parts.append(f"Web research indicates this is a {web_info.product_category}.")
        
        if web_info.applications:
            apps_str = ", ".join(web_info.applications)
            summary_parts.append(f"Common applications include {apps_str} sectors.")
        
        if web_info.specifications:
            specs_str = ", ".join(web_info.specifications)
            summary_parts.append(f"Technical characteristics: {specs_str}.")
        
        return " ".join(summary_parts) 
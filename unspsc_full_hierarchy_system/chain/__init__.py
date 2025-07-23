"""
Chain package for Production UNSPSC System

Contains the orchestration chain that coordinates all agents to perform complete UNSPSC classification.
"""

from .classification_chain import UNSPSCClassificationChain

__all__ = ['UNSPSCClassificationChain'] 
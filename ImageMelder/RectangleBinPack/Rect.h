/** @file Rect.h
	@author Jukka Jylänki

	This work is released to Public Domain, do whatever you want with it.
*/
#pragma once

#include <vector>

struct RBPRectSize
{
	int width;
	int height;
};

struct RBPRect
{
	int x;
	int y;
	int width;
	int height;
};

/// Performs a lexicographic compare on (rect short side, rect long side).
/// @return -1 if the smaller side of a is shorter than the smaller side of b, 1 if the other way around.
///   If they are equal, the larger side length is used as a tie-breaker.
///   If the rectangles are of same size, returns 0.
int CompareRectShortSide(const RBPRect &a, const RBPRect &b);

/// Performs a lexicographic compare on (x, y, width, height).
int NodeSortCmp(const RBPRect &a, const RBPRect &b);

/// Returns true if a is contained in b.
bool IsContainedIn(const RBPRect &a, const RBPRect &b);

class DisjointRectCollection
{
public:
	std::vector<RBPRect> rects;

	bool Add(const RBPRect &r)
	{
		// Degenerate rectangles are ignored.
		if (r.width == 0 || r.height == 0)
			return true;

		if (!Disjoint(r))
			return false;
		rects.push_back(r);
		return true;
	}

	void Clear()
	{
		rects.clear();
	}

	bool Disjoint(const RBPRect &r) const
	{
		// Degenerate rectangles are ignored.
		if (r.width == 0 || r.height == 0)
			return true;

		for(size_t i = 0; i < rects.size(); ++i)
			if (!Disjoint(rects[i], r))
				return false;
		return true;
	}

	static bool Disjoint(const RBPRect &a, const RBPRect &b)
	{
		if (a.x + a.width <= b.x ||
			b.x + b.width <= a.x ||
			a.y + a.height <= b.y ||
			b.y + b.height <= a.y)
			return true;
		return false;
	}
};
